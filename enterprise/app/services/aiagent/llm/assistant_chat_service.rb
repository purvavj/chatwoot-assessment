require 'openai'

class AIAgent::Llm::TopicChatService < Llm::BaseOpenAiService
  include AIAgent::ChatHelper

  def initialize(topic: nil)
    super()

    @topic = topic
    @messages = [system_message]
    @response = ''
    register_tools
  end

  def generate_response(input, previous_messages = [], role = 'user')
    @messages += previous_messages
    @messages << { role: role, content: input } if input.present?
    request_chat_completion
  end

  private

  def register_tools
    @tool_registry = AIAgent::ToolRegistryService.new(@topic, user: nil)
    @tool_registry.register_tool(AIAgent::Tools::SearchDocumentationService)
  end

  def system_message
    {
      role: 'system',
      content: AIAgent::Llm::SystemPromptsService.topic_response_generator(@topic.name, @topic.config['product_name'], @topic.config)
    }
  end

  def persist_message(message, message_type = 'topic')
    # No need to implement
  end
end
