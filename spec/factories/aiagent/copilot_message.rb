FactoryBot.define do
  factory :aiagent_copilot_message, class: 'CopilotMessage' do
    account
    copilot_thread { association :aiagent_copilot_thread }
    message { { content: 'This is a test message' } }
    message_type { 0 }
  end
end
