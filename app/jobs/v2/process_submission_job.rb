module V2
  class ProcessSubmissionJob < ApplicationJob
    queue_as :default

    attr_reader :request_id, :jwt_skew_override

    def perform(submission_id:, **options)
      @request_id = options[:request_id]
      @jwt_skew_override = options[:jwt_skew_override]

      Sentry.set_tags(request_id:)

      submission = Submission.find(submission_id)
      decrypted_submission = submission.decrypted_submission.merge('submission_id' => submission.id)
      payload_service = V2::SubmissionPayloadService.new(decrypted_submission)

      Sentry.set_context('attachments', { size: payload_service.attachments.size })

      decrypted_submission['actions'].each do |action|
        Sentry.set_context('action_payload', action.slice('kind', 'variant', 'include_attachments', 'include_pdf'))

        case action['kind']
        when 'json'
          JsonWebhookService.new(
            webhook_attachment_fetcher: WebhookAttachmentService.new(
              attachment_parser: AttachmentParserService.new(attachments: payload_service.attachments),
              user_file_store_gateway: Adapters::UserFileStore.new(key: submission.encrypted_user_id_and_token, request_id:)
            ),
            webhook_destination_adapter: Adapters::JweWebhookDestination.new(
              url: action['url'],
              key: action['key']
            )
          ).execute(
            user_answers: payload_service.user_answers,
            service_slug: submission.service_slug,
            payload_submission_id: payload_service.submission_id
          )
        when 'email'
          attachments = []
          pdf_attachment = nil

          if action['include_pdf'] == true
            pdf_api_gateway = Adapters::PdfApi.new(
              root_url: ENV.fetch('PDF_GENERATOR_ROOT_URL'),
              token: submission.access_token,
              request_id:
            )
            pdf_attachment = GeneratePdfContent.new(
              pdf_api_gateway:,
              payload: PdfPayloadTranslator.new(decrypted_submission).to_h
            ).execute
          end

          if action['include_attachments'] == true
            attachments = download_attachments(
              decrypted_submission['attachments'],
              submission.encrypted_user_id_and_token,
              submission.access_token
            )
          end

          send_email(submission:, action:, attachments:, pdf_attachment:)
        when 'csv'
          csv_attachment = V2::GenerateCsvContent.new(payload_service:).execute

          send_email(submission:, action:, attachments: [csv_attachment])
        when 'mslist'
          Rails.logger.info('*****************')
          Rails.logger.info('Creating adapter')
          ms_graph_adapter(action)

          if action['include_attachments'] == true
            attachments = download_attachments(
              decrypted_submission['attachments'],
              submission.encrypted_user_id_and_token,
              submission.access_token
            )

            attachments.each do |attachment|
              Rails.logger.info('*****************')
              Rails.logger.info('Posting attachment')
              Rails.logger.info(attachment.filename)
              send_attachment_to_drive(attachment, submission.id)
            end
          end

          # if send_to_ms_list(submission:)
          # if action['include_attachments'] == true
          #   attachments.each do |attachment|
          #     send_attachments_to_drive(attachment)
          #   end
          # end
          post_to_ms_list(decrypted_submission, submission.id)
          # end
        else
          Rails.logger.warn "Unknown action type '#{action}' for submission id #{submission.id}"
        end
      end
    end

    def download_attachments(attachments, encrypted_user_id_and_token, access_token)
      DownloadAttachments.new(
        attachments:,
        encrypted_user_id_and_token:,
        access_token:,
        request_id:,
        jwt_skew_override:
      ).download
    end

    def send_email(submission:, action:, attachments:, pdf_attachment: nil)
      EmailOutputService.new(
        emailer: EmailService,
        attachment_generator: AttachmentGenerator.new,
        encryption_service: EncryptionService.new,
        submission_id: submission.id,
        payload_submission_id: submission.id
      ).execute(
        action: action.symbolize_keys,
        attachments:,
        pdf_attachment:
      )
    end

    delegate :send_attachment_to_drive, :post_to_ms_list, to: :ms_graph_adapter

    def ms_graph_adapter(action = nil)
      @ms_graph_adapter ||= V2::SendToMsGraphService.new(action)
    end
  end
end
