module Enterprise::Concerns::Inbox
  extend ActiveSupport::Concern

  included do
    has_one :aiagent_inbox, dependent: :destroy, class_name: 'AIAgentInbox'
    has_one :aiagent_topic,
            through: :aiagent_inbox,
            class_name: 'AIAgent::Topic'
  end
end
