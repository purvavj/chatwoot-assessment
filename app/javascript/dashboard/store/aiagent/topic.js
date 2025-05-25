import AIAgentTopicAPI from 'dashboard/api/aiagent/topic';
import { createStore } from './storeFactory';

export default createStore({
  name: 'AIAgentTopic',
  API: AIAgentTopicAPI,
});
