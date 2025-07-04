class AIAgent::Documents::CrawlJob < ApplicationJob
  queue_as :low

  def perform(document)
    if InstallationConfig.find_by(name: 'AI_AGENT_FIRECRAWL_API_KEY')&.value.present?
      perform_firecrawl_crawl(document)
    else
      perform_simple_crawl(document)
    end
  end

  private

  include AIAgent::FirecrawlHelper

  def perform_simple_crawl(document)
    page_links = AIAgent::Tools::SimplePageCrawlService.new(document.external_link).page_links

    page_links.each do |page_link|
      AIAgent::Tools::SimplePageCrawlParserJob.perform_later(
        topic_id: document.topic_id,
        page_link: page_link
      )
    end

    AIAgent::Tools::SimplePageCrawlParserJob.perform_later(
      topic_id: document.topic_id,
      page_link: document.external_link
    )
  end

  def perform_firecrawl_crawl(document)
    aiagent_usage_limits = document.account.usage_limits[:aiagent] || {}
    document_limit = aiagent_usage_limits[:documents] || {}
    crawl_limit = [document_limit[:current_available] || 10, 500].min

    AIAgent::Tools::FirecrawlService
      .new
      .perform(
        document.external_link,
        firecrawl_webhook_url(document),
        crawl_limit
      )
  end

  def firecrawl_webhook_url(document)
    webhook_url = Rails.application.routes.url_helpers.enterprise_webhooks_firecrawl_url

    "#{webhook_url}?topic_id=#{document.topic_id}&token=#{generate_firecrawl_token(document.topic_id, document.account_id)}"
  end
end
