class AIAgent::InboxPendingConversationsResolutionJob < ApplicationJob
  queue_as :low

  def perform(inbox)
    Current.executed_by = inbox.aiagent_topic

    resolvable_conversations = inbox.conversations.pending.where('last_activity_at < ? ', Time.now.utc - 1.hour).limit(Limits::BULK_ACTIONS_LIMIT)
    resolvable_conversations.each do |conversation|
      create_outgoing_message(conversation, inbox)
      conversation.resolved!
    end
  ensure
    Current.reset
  end

  private

  def create_outgoing_message(conversation, inbox)
    I18n.with_locale(inbox.account.locale) do
      resolution_message = inbox.aiagent_topic.config['resolution_message']
      conversation.messages.create!(
        {
          message_type: :outgoing,
          account_id: conversation.account_id,
          inbox_id: conversation.inbox_id,
          content: resolution_message.presence || I18n.t('conversations.activity.auto_resolution_message'),
          sender: inbox.aiagent_topic
        }
      )
    end
  end
end
