require 'rails_helper'

describe ActionCableListener do
  describe '#copilot_message_created' do
    let(:event_name) { :copilot_message_created }
    let(:account) { create(:account) }
    let(:user) { create(:user, account: account) }
    let(:topic) { create(:aiagent_topic, account: account) }
    let(:copilot_thread) { create(:aiagent_copilot_thread, account: account, user: user, topic: topic) }
    let(:copilot_message) { create(:aiagent_copilot_message, copilot_thread: copilot_thread) }
    let(:event) { Events::Base.new(event_name, Time.zone.now, copilot_message: copilot_message) }
    let(:listener) { described_class.instance }

    it 'broadcasts message to the user' do
      expect(ActionCableBroadcastJob).to receive(:perform_later).with(
        [user.pubsub_token],
        'copilot.message.created',
        copilot_message.push_event_data.merge(account_id: account.id)
      )

      listener.copilot_message_created(event)
    end
  end
end
