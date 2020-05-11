require 'rails_helper'

RSpec.describe DbSweeper do
  describe '#call' do
    context 'when there are submissions over 28 days old' do
      before do
        create(:submission, created_at: 30.days.ago)
        create(:submission, created_at: 5.days.ago)
      end

      it 'destroys the older submission records' do
        expect do
          subject.call
        end.to change(Submission, :count).by(-1)
      end
    end

    context 'when there are no submissions over 28 days old' do
      before do
        create(:submission, created_at: 5.days.ago)
      end

      it 'leaves submission records intact' do
        expect do
          subject.call
        end.not_to change(Submission, :count)
      end
    end

    context 'when there are email payloads over 7 days old' do
      before do
        create(:email_payload, created_at: 10.days.ago)
        create(:email_payload, created_at: 10.days.ago, succeeded_at: 10.days.ago)
        create(:email_payload, created_at: 5.days.ago, succeeded_at: 5.days.ago)
      end

      it 'destroys the older records unless email sending failed' do
        expect do
          subject.call
        end.to change(EmailPayload, :count).by(-1)
      end
    end

    context 'when there are no email payloads over 7 days old' do
      before do
        create(:email_payload, created_at: 5.days.ago)
      end

      it 'leaves email payload records intact' do
        expect do
          subject.call
        end.not_to change(EmailPayload, :count)
      end
    end
  end
end
