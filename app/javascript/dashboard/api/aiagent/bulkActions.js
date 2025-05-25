import ApiClient from '../ApiClient';

class AIAgentBulkActionsAPI extends ApiClient {
  constructor() {
    super('aiagent/bulk_actions', { accountScoped: true });
  }
}

export default new AIAgentBulkActionsAPI();
