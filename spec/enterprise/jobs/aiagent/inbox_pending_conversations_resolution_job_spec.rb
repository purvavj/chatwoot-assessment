require 'rails_helper'

RSpec.describe AIAgent::InboxPendingConversationsResolutionJob, type: :job do
  include ActiveJob::TestHelper

  let!(:inbox) { create(:inbox) }

  let!(:resolvable_pending_conversation) { create(:conversation, inbox: inbox, last_activity_at: 2.hours.ago, status: :pending) }
  let!(:recent_pending_conversation) { create(:conversation, inbox: inbox, last_activity_at: 10.minutes.ago, status: :pending) }
  let!(:open_conversation) { create(:conversation, inbox: inbox, last_activity_at: 1.hour.ago, status: :open) }

  let!(:aiagent_topic) { create(:aiagent_topic, account: inbox.account) }

  before do
    create(:aiagent_inbox, inbox: inbox, aiagent_topic: aiagent_topic)
    stub_const('Limits::BULK_ACTIONS_LIMIT', 2)
  end

  it 'queues the job' do
    expect { described_class.perform_later(inbox) }
      .to have_enqueued_job.on_queue('low')
  end

  it 'resolves only the eligible pending conversations' do
    perform_enqueued_jobs { described_class.perform_later(inbox) }

    expect(resolvable_pending_conversation.reload.status).to eq('resolved')
    expect(recent_pending_conversation.reload.status).to eq('pending')
    expect(open_conversation.reload.status).to eq('open')
  end

  it 'creates exactly one outgoing message with configured content' do
    custom_message = 'This is a custom resolution message.'
    aiagent_topic.update!(config: { 'resolution_message' => custom_message })

    expect do
      perform_enqueued_jobs { described_class.perform_later(inbox) }
    end.to change { resolvable_pending_conversation.messages.outgoing.reload.count }.by(1)

    outgoing_message = resolvable_pending_conversation.messages.outgoing.last
    expect(outgoing_message.content).to eq(custom_message)
  end

  it 'creates an outgoing message with default auto resolution message if not configured' do
    aiagent_topic.update!(config: {})

    perform_enqueued_jobs { described_class.perform_later(inbox) }
    outgoing_message = resolvable_pending_conversation.messages.outgoing.last
    expect(outgoing_message.content).to eq(
      I18n.t('conversations.activity.auto_resolution_message')
    )
  end

  it 'adds the correct activity message after resolution by AI Agent' do
    perform_enqueued_jobs { described_class.perform_later(inbox) }
    activity_message = resolvable_pending_conversation.messages.activity.last
    expect(activity_message).not_to be_nil
    expect(activity_message.content).to eq(
      I18n.t('conversations.activity.aiagent.resolved', user_name: aiagent_topic.name)
    )
  end
end
