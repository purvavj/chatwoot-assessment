import AIAgentDocumentAPI from 'dashboard/api/aiagent/document';
import { createStore } from './storeFactory';

export default createStore({
  name: 'AIAgentDocument',
  API: AIAgentDocumentAPI,
});
