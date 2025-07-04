class AIAgent::Documents::ResponseBuilderJob < ApplicationJob
  queue_as :low

  def perform(document)
    reset_previous_responses(document)

    faqs = AIAgent::Llm::FaqGeneratorService.new(document.content).generate
    faqs.each do |faq|
      create_response(faq, document)
    end
  end

  private

  def reset_previous_responses(response_document)
    response_document.responses.destroy_all
  end

  def create_response(faq, document)
    document.responses.create!(
      question: faq['question'],
      answer: faq['answer'],
      topic: document.topic,
      documentable: document
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Error in creating response document: #{e.message}"
  end
end
