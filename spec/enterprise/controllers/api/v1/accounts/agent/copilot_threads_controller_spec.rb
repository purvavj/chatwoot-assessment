require 'rails_helper'

RSpec.describe 'Api::V1::Accounts::AIAgent::CopilotThreads', type: :request do
  let(:account) { create(:account) }
  let(:admin) { create(:user, account: account, role: :administrator) }
  let(:agent) { create(:user, account: account, role: :agent) }

  def json_response
    JSON.parse(response.body, symbolize_names: true)
  end

  describe 'GET /api/v1/accounts/{account.id}/aiagent/copilot_threads' do
    context 'when it is an un-authenticated user' do
      it 'does not fetch copilot threads' do
        get "/api/v1/accounts/#{account.id}/aiagent/copilot_threads",
            as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated user' do
      it 'fetches copilot threads for the current user' do
        # Create threads for the current agent
        create_list(:aiagent_copilot_thread, 3, account: account, user: agent)
        # Create threads for another user (should not be included)
        create_list(:aiagent_copilot_thread, 2, account: account, user: admin)

        get "/api/v1/accounts/#{account.id}/aiagent/copilot_threads",
            headers: agent.create_new_auth_token,
            as: :json

        expect(response).to have_http_status(:success)
        expect(json_response[:payload].length).to eq(3)

        expect(json_response[:payload].map { |thread| thread[:user][:id] }.uniq).to eq([agent.id])
      end

      it 'returns threads in descending order of creation' do
        threads = create_list(:aiagent_copilot_thread, 3, account: account, user: agent)

        get "/api/v1/accounts/#{account.id}/aiagent/copilot_threads",
            headers: agent.create_new_auth_token,
            as: :json

        expect(response).to have_http_status(:success)
        expect(json_response[:payload].pluck(:id)).to eq(threads.reverse.pluck(:id))
      end
    end
  end

  describe 'POST /api/v1/accounts/{account.id}/aiagent/copilot_threads' do
    let(:topic) { create(:aiagent_topic, account: account) }
    let(:valid_params) { { message: 'Hello, how can you help me?', topic_id: topic.id } }

    context 'when it is an un-authenticated user' do
      it 'returns unauthorized' do
        post "/api/v1/accounts/#{account.id}/aiagent/copilot_threads",
             params: valid_params,
             as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated user' do
      context 'with invalid params' do
        it 'returns error when message is blank' do
          post "/api/v1/accounts/#{account.id}/aiagent/copilot_threads",
               params: { message: '', topic_id: topic.id },
               headers: agent.create_new_auth_token,
               as: :json

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response[:error]).to eq('Message is required')
        end

        it 'returns error when topic_id is invalid' do
          post "/api/v1/accounts/#{account.id}/aiagent/copilot_threads",
               params: { message: 'Hello', topic_id: 0 },
               headers: agent.create_new_auth_token,
               as: :json

          expect(response).to have_http_status(:not_found)
        end
      end

      context 'with valid params' do
        it 'creates a new copilot thread with initial message' do
          expect do
            post "/api/v1/accounts/#{account.id}/aiagent/copilot_threads",
                 params: valid_params,
                 headers: agent.create_new_auth_token,
                 as: :json
          end.to change(CopilotThread, :count).by(1)
             .and change(CopilotMessage, :count).by(1)

          expect(response).to have_http_status(:success)

          thread = CopilotThread.last
          expect(thread.title).to eq(valid_params[:message])
          expect(thread.user_id).to eq(agent.id)
          expect(thread.topic_id).to eq(topic.id)

          message = thread.copilot_messages.last
          expect(message.message_type).to eq('user')
          expect(message.message).to eq(valid_params[:message])
        end
      end
    end
  end
end
