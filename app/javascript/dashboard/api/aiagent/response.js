/* global axios */
import ApiClient from '../ApiClient';

class AIAgentResponses extends ApiClient {
  constructor() {
    super('aiagent/topic_responses', { accountScoped: true });
  }

  get({ page = 1, searchKey, assistantId, documentId, status } = {}) {
    return axios.get(this.url, {
      params: {
        page,
        searchKey,
        assistant_id: assistantId,
        document_id: documentId,
        status,
      },
    });
  }
}

export default new AIAgentResponses();
