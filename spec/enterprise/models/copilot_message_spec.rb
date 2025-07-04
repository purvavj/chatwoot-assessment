require 'rails_helper'

RSpec.describe CopilotMessage, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:copilot_thread) }
    it { is_expected.to belong_to(:account) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:message_type) }
    it { is_expected.to validate_presence_of(:message) }
    it { is_expected.to validate_inclusion_of(:message_type).in_array(described_class.message_types.keys) }
  end

  describe 'callbacks' do
    let(:account) { create(:account) }
    let(:user) { create(:user, account: account) }
    let(:topic) { create(:aiagent_topic, account: account) }
    let(:copilot_thread) { create(:aiagent_copilot_thread, account: account, user: user, topic: topic) }

    describe '#ensure_account' do
      it 'sets the account from the copilot thread before validation' do
        message = build(:aiagent_copilot_message, copilot_thread: copilot_thread, account: nil)
        message.valid?
        expect(message.account).to eq(copilot_thread.account)
      end
    end

    describe '#broadcast_message' do
      it 'dispatches COPILOT_MESSAGE_CREATED event after create' do
        message = build(:aiagent_copilot_message, copilot_thread: copilot_thread)

        expect(Rails.configuration.dispatcher).to receive(:dispatch)
          .with(COPILOT_MESSAGE_CREATED, anything, copilot_message: message)

        message.save!
      end
    end
  end

  describe '#push_event_data' do
    let(:account) { create(:account) }
    let(:user) { create(:user, account: account) }
    let(:topic) { create(:aiagent_topic, account: account) }
    let(:copilot_thread) { create(:aiagent_copilot_thread, account: account, user: user, topic: topic) }
    let(:message_content) { { 'content' => 'Test message' } }
    let(:copilot_message) do
      create(:aiagent_copilot_message,
             copilot_thread: copilot_thread,
             message_type: 'user',
             message: message_content)
    end

    it 'returns the correct event data' do
      event_data = copilot_message.push_event_data

      expect(event_data[:id]).to eq(copilot_message.id)
      expect(event_data[:message]).to eq(message_content)
      expect(event_data[:message_type]).to eq('user')
      expect(event_data[:created_at]).to eq(copilot_message.created_at.to_i)
      expect(event_data[:copilot_thread]).to eq(copilot_thread.push_event_data)
    end
  end
end
