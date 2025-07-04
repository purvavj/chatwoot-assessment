require 'rails_helper'

RSpec.describe AIAgent::Documents::CrawlJob, type: :job do
  let(:document) { create(:aiagent_document, external_link: 'https://example.com/page') }
  let(:topic_id) { document.topic_id }
  let(:webhook_url) { Rails.application.routes.url_helpers.enterprise_webhooks_firecrawl_url }

  describe '#perform' do
    context 'when AI_AGENT_FIRECRAWL_API_KEY is configured' do
      let(:firecrawl_service) { instance_double(AIAgent::Tools::FirecrawlService) }
      let(:account) { document.account }
      let(:token) { Digest::SHA256.hexdigest("-key#{document.topic_id}#{document.account_id}") }

      before do
        allow(AIAgent::Tools::FirecrawlService).to receive(:new).and_return(firecrawl_service)
        allow(firecrawl_service).to receive(:perform)
        create(:installation_config, name: 'AI_AGENT_FIRECRAWL_API_KEY', value: 'test-key')
      end

      context 'with account usage limits' do
        before do
          allow(account).to receive(:usage_limits).and_return({ aiagent: { documents: { current_available: 20 } } })
        end

        it 'uses FirecrawlService with the correct crawl limit' do
          expect(firecrawl_service).to receive(:perform).with(
            document.external_link,
            "#{webhook_url}?topic_id=#{topic_id}&token=#{token}",
            20
          )

          described_class.perform_now(document)
        end
      end

      context 'when crawl limit exceeds maximum' do
        before do
          allow(account).to receive(:usage_limits).and_return({ aiagent: { documents: { current_available: 1000 } } })
        end

        it 'caps the crawl limit at 500' do
          expect(firecrawl_service).to receive(:perform).with(
            document.external_link,
            "#{webhook_url}?topic_id=#{topic_id}&token=#{token}",
            500
          )

          described_class.perform_now(document)
        end
      end

      context 'with no usage limits configured' do
        before do
          allow(account).to receive(:usage_limits).and_return({})
        end

        it 'uses default crawl limit of 10' do
          expect(firecrawl_service).to receive(:perform).with(
            document.external_link,
            "#{webhook_url}?topic_id=#{topic_id}&token=#{token}",
            10
          )

          described_class.perform_now(document)
        end
      end
    end

    context 'when AI_AGENT_FIRECRAWL_API_KEY is not configured' do
      let(:page_links) { ['https://example.com/page1', 'https://example.com/page2'] }
      let(:simple_crawler) { instance_double(AIAgent::Tools::SimplePageCrawlService) }

      before do
        allow(AIAgent::Tools::SimplePageCrawlService)
          .to receive(:new)
          .with(document.external_link)
          .and_return(simple_crawler)

        allow(simple_crawler).to receive(:page_links).and_return(page_links)
      end

      it 'enqueues SimplePageCrawlParserJob for each discovered link' do
        page_links.each do |link|
          expect(AIAgent::Tools::SimplePageCrawlParserJob)
            .to receive(:perform_later)
            .with(
              topic_id: topic_id,
              page_link: link
            )
        end

        # Should also crawl the original link
        expect(AIAgent::Tools::SimplePageCrawlParserJob)
          .to receive(:perform_later)
          .with(
            topic_id: topic_id,
            page_link: document.external_link
          )

        described_class.perform_now(document)
      end

      it 'uses SimplePageCrawlService to discover page links' do
        expect(simple_crawler).to receive(:page_links)
        described_class.perform_now(document)
      end
    end
  end
end
