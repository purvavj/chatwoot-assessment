import AIAgentAssistantAPI from 'dashboard/api/aiagent/topic';
import { createStore } from './storeFactory';

export default createStore({
  name: 'AIAgentAssistant',
  API: AIAgentAssistantAPI,
});
