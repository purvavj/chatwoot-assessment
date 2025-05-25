FactoryBot.define do
  factory :aiagent_copilot_thread, class: 'CopilotThread' do
    account
    user
    title { Faker::Lorem.sentence }
    assistant { create(:aiagent_assistant, account: account) }
  end
end
