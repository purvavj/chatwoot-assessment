FactoryBot.define do
  factory :aiagent_copilot_thread, class: 'CopilotThread' do
    account
    user
    title { Faker::Lorem.sentence }
    topic { create(:aiagent_topic, account: account) }
  end
end
