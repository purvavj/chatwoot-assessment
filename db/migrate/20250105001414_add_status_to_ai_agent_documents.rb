class AddStatusToAIAgentDocuments < ActiveRecord::Migration[7.0]
  def change
    add_column :aiagent_documents, :status, :integer, null: false, default: 0
    add_index :aiagent_documents, :status
  end
end
