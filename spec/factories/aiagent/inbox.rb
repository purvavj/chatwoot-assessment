FactoryBot.define do
  factory :aiagent_inbox, class: 'AIAgentInbox' do
    association :aiagent_topic, factory: :aiagent_topic
    association :inbox
  end
end
