class RenameAIAgentAssistantIdToTopicIdInAIAgentInboxes < ActiveRecord::Migration[7.0]
  def change
    # drop the old unique index if it exists
    if index_exists?(:aiagent_inboxes,
                     [:aiagent_assistant_id, :inbox_id],
                     name: 'index_aiagent_inboxes_on_aiagent_assistant_id_and_inbox_id')
      remove_index :aiagent_inboxes,
                   name: 'index_aiagent_inboxes_on_aiagent_assistant_id_and_inbox_id'
    end

    # rename the column
    rename_column :aiagent_inboxes,
                  :aiagent_assistant_id,
                  :aiagent_topic_id

    # recreate the unique index with the new column name
    add_index :aiagent_inboxes,
              [:aiagent_topic_id, :inbox_id],
              unique: true,
              name: 'index_aiagent_inboxes_on_aiagent_topic_id_and_inbox_id'
  end
end
