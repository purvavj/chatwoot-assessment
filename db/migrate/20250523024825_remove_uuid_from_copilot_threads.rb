class RemoveUuidFromCopilotThreads < ActiveRecord::Migration[7.1]
  def change
    remove_column :copilot_threads, :uuid, :string

    add_column :copilot_threads, :topic_id, :integer
    add_index :copilot_threads, :topic_id
  end
end
