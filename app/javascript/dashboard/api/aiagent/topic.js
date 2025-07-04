/* global axios */
import ApiClient from '../ApiClient';

class AIAgentTopic extends ApiClient {
  constructor() {
    super('aiagent/topics', { accountScoped: true });
  }

  get({ page = 1, searchKey } = {}) {
    return axios.get(this.url, {
      params: {
        page,
        searchKey,
      },
    });
  }

  playground({ topicId, messageContent, messageHistory }) {
    return axios.post(`${this.url}/${topicId}/playground`, {
      message_content: messageContent,
      message_history: messageHistory,
    });
  }
}

export default new AIAgentTopic();
