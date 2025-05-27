class AddCachedLabelsList < ActiveRecord::Migration[7.0]
  def change
    add_column :conversations, :cached_label_list, :string
    # Conversation.reset_column_information
    # ActsAsTaggableOn::Taggable::Cache.included(Conversation)
    add_index  :conversations, :cached_label_list,
               name: 'index_conversations_on_cached_label_list'
  end
end
