require 'rails_helper'

RSpec.describe 'Api::V1::Accounts::AIAgent::TopicResponses', type: :request do
  let(:account) { create(:account) }
  let(:topic) { create(:aiagent_topic, account: account) }
  let(:document) { create(:aiagent_document, topic: topic, account: account) }
  let(:admin) { create(:user, account: account, role: :administrator) }
  let(:agent) { create(:user, account: account, role: :agent) }
  let(:another_topic) { create(:aiagent_topic, account: account) }
  let(:another_document) { create(:aiagent_document, account: account, topic: topic) }

  def json_response
    JSON.parse(response.body, symbolize_names: true)
  end

  describe 'GET /api/v1/accounts/:account_id/aiagent/topic_responses' do
    context 'when no filters are applied' do
      before do
        create_list(:aiagent_topic_response, 30,
                    account: account,
                    topic: topic,
                    documentable: document)
      end

      it 'returns first page of responses with default pagination' do
        get "/api/v1/accounts/#{account.id}/aiagent/topic_responses",
            headers: agent.create_new_auth_token,
            as: :json

        expect(response).to have_http_status(:ok)
        expect(json_response[:payload].length).to eq(25)
      end

      it 'returns second page of responses' do
        get "/api/v1/accounts/#{account.id}/aiagent/topic_responses",
            params: { page: 2 },
            headers: agent.create_new_auth_token,
            as: :json

        expect(response).to have_http_status(:ok)
        expect(json_response[:payload].length).to eq(5)
        expect(json_response[:meta]).to eq({ page: 2, total_count: 30 })
      end
    end

    context 'when filtering by topic_id' do
      before do
        create_list(:aiagent_topic_response, 3,
                    account: account,
                    topic: topic,
                    documentable: document)
        create_list(:aiagent_topic_response, 2,
                    account: account,
                    topic: another_topic,
                    documentable: document)
      end

      it 'returns only responses for the specified topic' do
        get "/api/v1/accounts/#{account.id}/aiagent/topic_responses",
            params: { topic_id: topic.id },
            headers: agent.create_new_auth_token,
            as: :json

        expect(response).to have_http_status(:ok)
        expect(json_response[:payload].length).to eq(3)
        expect(json_response[:payload][0][:topic][:id]).to eq(topic.id)
      end
    end

    context 'when filtering by document_id' do
      before do
        create_list(:aiagent_topic_response, 3,
                    account: account,
                    topic: topic,
                    documentable: document)
        create_list(:aiagent_topic_response, 2,
                    account: account,
                    topic: topic,
                    documentable: another_document)
      end

      it 'returns only responses for the specified document' do
        get "/api/v1/accounts/#{account.id}/aiagent/topic_responses",
            params: { document_id: document.id },
            headers: agent.create_new_auth_token,
            as: :json

        expect(response).to have_http_status(:ok)
        expect(json_response[:payload].length).to eq(3)
        expect(json_response[:payload][0][:documentable][:id]).to eq(document.id)
      end
    end
  end

  describe 'GET /api/v1/accounts/:account_id/aiagent/topic_responses/:id' do
    let!(:response_record) { create(:aiagent_topic_response, topic: topic, account: account) }

    it 'returns the requested response if the user is agent or admin' do
      get "/api/v1/accounts/#{account.id}/aiagent/topic_responses/#{response_record.id}",
          headers: agent.create_new_auth_token,
          as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response[:id]).to eq(response_record.id)
      expect(json_response[:question]).to eq(response_record.question)
      expect(json_response[:answer]).to eq(response_record.answer)
    end
  end

  describe 'POST /api/v1/accounts/:account_id/aiagent/topic_responses' do
    let(:valid_params) do
      {
        topic_response: {
          question: 'Test question?',
          answer: 'Test answer',
          topic_id: topic.id
        }
      }
    end

    it 'creates a new response if the user is an admin' do
      expect do
        post "/api/v1/accounts/#{account.id}/aiagent/topic_responses",
             params: valid_params,
             headers: admin.create_new_auth_token,
             as: :json
      end.to change(AIAgent::TopicResponse, :count).by(1)

      expect(response).to have_http_status(:success)

      expect(json_response[:question]).to eq('Test question?')
      expect(json_response[:answer]).to eq('Test answer')
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          topic_response: {
            question: 'Test',
            answer: 'Test'
          }
        }
      end

      it 'returns unprocessable entity status' do
        post "/api/v1/accounts/#{account.id}/aiagent/topic_responses",
             params: invalid_params,
             headers: admin.create_new_auth_token,
             as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /api/v1/accounts/:account_id/aiagent/topic_responses/:id' do
    let!(:response_record) { create(:aiagent_topic_response, topic: topic) }
    let(:update_params) do
      {
        topic_response: {
          question: 'Updated question?',
          answer: 'Updated answer'
        }
      }
    end

    it 'updates the response if the user is an admin' do
      patch "/api/v1/accounts/#{account.id}/aiagent/topic_responses/#{response_record.id}",
            params: update_params,
            headers: admin.create_new_auth_token,
            as: :json

      expect(response).to have_http_status(:ok)

      expect(json_response[:question]).to eq('Updated question?')
      expect(json_response[:answer]).to eq('Updated answer')
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          topic_response: {
            question: '',
            answer: ''
          }
        }
      end

      it 'returns unprocessable entity status' do
        patch "/api/v1/accounts/#{account.id}/aiagent/topic_responses/#{response_record.id}",
              params: invalid_params,
              headers: admin.create_new_auth_token,
              as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /api/v1/accounts/:account_id/aiagent/topic_responses/:id' do
    let!(:response_record) { create(:aiagent_topic_response, topic: topic) }

    it 'deletes the response' do
      expect do
        delete "/api/v1/accounts/#{account.id}/aiagent/topic_responses/#{response_record.id}",
               headers: admin.create_new_auth_token,
               as: :json
      end.to change(AIAgent::TopicResponse, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    context 'with invalid id' do
      it 'returns not found' do
        delete "/api/v1/accounts/#{account.id}/aiagent/topic_responses/0",
               headers: admin.create_new_auth_token,
               as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
