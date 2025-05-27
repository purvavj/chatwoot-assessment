class AddConfigToAIAgentTopic < ActiveRecord::Migration[7.0]
  def change
    add_column :aiagent_topics, :config, :jsonb, default: {}, null: false
  end
end
