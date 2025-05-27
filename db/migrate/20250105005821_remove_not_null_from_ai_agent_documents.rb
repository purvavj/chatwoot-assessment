class RemoveNotNullFromAIAgentDocuments < ActiveRecord::Migration[7.0]
  def change
    change_column_null :aiagent_documents, :name, true
  end
end
