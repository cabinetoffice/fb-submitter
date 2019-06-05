class SmsController < ApplicationController
  # example json payload:
  #
  # {
  #   sms: {
  #     to: '07123456789',
  #     body: 'body as string goes here',
  #     template_name: 'name-of-template',
  #     [extra_personalisation]: {
  #       token: 'my-token'
  #     }
  #   }
  # }
  #
  def create
    return render_errors unless sms_validator.valid?

    if job_class.perform_later(sms: sms_params)
      return render json: {}, status: :created
    end
  end

  private

  def sms_validator
    Sms.new(sms_params)
  end

  def render_errors
    render json: { name: 'bad-request.invalid-parameters' }, status: :bad_request
  end

  def sms_params
    params.require(:sms).permit(:to,
                                :body,
                                :template_name,
                                extra_personalisation: [:code])
  end

  def job_class
    SmsJob
  end
end