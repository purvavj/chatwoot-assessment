require 'rails_helper'

RSpec.describe 'Api::V1::Accounts::AIAgent::Inboxes', type: :request do
  let(:account) { create(:account) }
  let(:topic) { create(:aiagent_topic, account: account) }
  let(:inbox) { create(:inbox, account: account) }
  let(:inbox2) { create(:inbox, account: account) }
  let!(:aiagent_inbox) { create(:aiagent_inbox, aiagent_topic: topic, inbox: inbox) }
  let(:admin) { create(:user, account: account, role: :administrator) }
  let(:agent) { create(:user, account: account, role: :agent) }

  def json_response
    JSON.parse(response.body, symbolize_names: true)
  end

  describe 'GET /api/v1/accounts/:account_id/aiagent/topics/:topic_id/inboxes' do
    context 'when user is authorized' do
      it 'returns a list of inboxes for the topic' do
        get "/api/v1/accounts/#{account.id}/aiagent/topics/#{topic.id}/inboxes",
            headers: agent.create_new_auth_token

        expect(response).to have_http_status(:ok)
        expect(json_response[:payload].first[:id]).to eq(aiagent_inbox.inbox.id)
      end
    end

    context 'when user is unauthorized' do
      it 'returns unauthorized status' do
        get "/api/v1/accounts/#{account.id}/aiagent/topics/#{topic.id}/inboxes"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when topic does not exist' do
      it 'returns not found status' do
        get "/api/v1/accounts/#{account.id}/aiagent/topics/999999/inboxes",
            headers: agent.create_new_auth_token

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/accounts/:account/aiagent/topics/:topic_id/inboxes' do
    let(:valid_params) do
      {
        inbox: {
          inbox_id: inbox2.id
        }
      }
    end

    context 'when user is authorized' do
      it 'creates a new aiagent inbox' do
        expect do
          post "/api/v1/accounts/#{account.id}/aiagent/topics/#{topic.id}/inboxes",
               params: valid_params,
               headers: admin.create_new_auth_token
        end.to change(AIAgentInbox, :count).by(1)

        expect(response).to have_http_status(:success)
        expect(json_response[:id]).to eq(inbox2.id)
      end

      context 'when inbox does not exist' do
        it 'returns not found status' do
          post "/api/v1/accounts/#{account.id}/aiagent/topics/#{topic.id}/inboxes",
               params: { inbox: { inbox_id: 999_999 } },
               headers: admin.create_new_auth_token

          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when params are invalid' do
        it 'returns unprocessable entity status' do
          post "/api/v1/accounts/#{account.id}/aiagent/topics/#{topic.id}/inboxes",
               params: {},
               headers: admin.create_new_auth_token

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when user is agent' do
      it 'returns unauthorized status' do
        post "/api/v1/accounts/#{account.id}/aiagent/topics/#{topic.id}/inboxes",
             params: valid_params,
             headers: agent.create_new_auth_token

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/accounts/aiagent/topics/:topic_id/inboxes/:inbox_id' do
    context 'when user is authorized' do
      it 'deletes the aiagent inbox' do
        expect do
          delete "/api/v1/accounts/#{account.id}/aiagent/topics/#{topic.id}/inboxes/#{inbox.id}",
                 headers: admin.create_new_auth_token
        end.to change(AIAgentInbox, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end

      context 'when aiagent inbox does not exist' do
        it 'returns not found status' do
          delete "/api/v1/accounts/#{account.id}/aiagent/topics/#{topic.id}/inboxes/999999",
                 headers: admin.create_new_auth_token

          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
