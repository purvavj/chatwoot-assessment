import AIAgentBulkActionsAPI from 'dashboard/api/aiagent/bulkActions';
import { createStore } from './storeFactory';
import { throwErrorMessage } from 'dashboard/store/utils/api';

export default createStore({
  name: 'AIAgentBulkAction',
  API: AIAgentBulkActionsAPI,
  actions: mutations => ({
    processBulkAction: async function processBulkAction(
      { commit },
      { type, actionType, ids }
    ) {
      commit(mutations.SET_UI_FLAG, { isUpdating: true });
      try {
        const response = await AIAgentBulkActionsAPI.create({
          type: type,
          ids,
          fields: { status: actionType },
        });
        commit(mutations.SET_UI_FLAG, { isUpdating: false });
        return response.data;
      } catch (error) {
        commit(mutations.SET_UI_FLAG, { isUpdating: false });
        return throwErrorMessage(error);
      }
    },

    handleBulkDelete: async function handleBulkDelete({ dispatch }, ids) {
      const response = await dispatch('processBulkAction', {
        type: 'TopicResponse',
        actionType: 'delete',
        ids,
      });

      // Update the response store after successful API call
      await dispatch('aiagentResponses/removeBulkResponses', ids, {
        root: true,
      });
      return response;
    },

    handleBulkApprove: async function handleBulkApprove({ dispatch }, ids) {
      const response = await dispatch('processBulkAction', {
        type: 'TopicResponse',
        actionType: 'approve',
        ids,
      });

      // Update response store after successful API call
      await dispatch('aiagentResponses/updateBulkResponses', response, {
        root: true,
      });
      return response;
    },
  }),
});
