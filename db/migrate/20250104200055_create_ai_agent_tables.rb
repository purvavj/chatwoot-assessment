class CreateAIAgentTables < ActiveRecord::Migration[7.0]
  def up
    # Post this migration, the 'vector' extension is mandatory to run the application.
    # If the extension is not installed, the migration will raise an error.
    setup_vector_extension
    create_topics
    create_documents
    create_topic_responses
    create_old_tables
  end

  def down
    drop_table :aiagent_topic_responses if table_exists?(:aiagent_topic_responses)
    drop_table :aiagent_documents if table_exists?(:aiagent_documents)
    drop_table :aiagent_topics if table_exists?(:aiagent_topics)
    drop_table :article_embeddings if table_exists?(:article_embeddings)

    # We are not disabling the extension here because it might be
    # used by other tables which are not part of this migration.
  end

  private

  def setup_vector_extension
    return if extension_enabled?('vector')

    begin
      enable_extension 'vector'
    rescue ActiveRecord::StatementInvalid
      raise StandardError, "Failed to enable 'vector' extension. Read more at https://chwt.app/v4/migration"
    end
  end

  def create_topics
    create_table :aiagent_topics do |t|
      t.string :name, null: false
      t.bigint :account_id, null: false
      t.string :description

      t.timestamps
    end

    add_index :aiagent_topics, :account_id
    add_index :aiagent_topics, [:account_id, :name], unique: true
  end

  def create_documents
    create_table :aiagent_documents do |t|
      t.string :name, null: false
      t.string :external_link, null: false
      t.text :content
      t.bigint :topic_id, null: false
      t.bigint :account_id, null: false

      t.timestamps
    end

    add_index :aiagent_documents, :account_id
    add_index :aiagent_documents, :topic_id
    add_index :aiagent_documents, [:topic_id, :external_link], unique: true
  end

  def create_topic_responses
    create_table :aiagent_topic_responses do |t|
      t.string :question, null: false
      t.text :answer, null: false
      t.vector :embedding, limit: 1536
      t.bigint :topic_id, null: false
      t.bigint :document_id
      t.bigint :account_id, null: false

      t.timestamps
    end

    add_index :aiagent_topic_responses, :account_id
    add_index :aiagent_topic_responses, :topic_id
    add_index :aiagent_topic_responses, :document_id
    add_index :aiagent_topic_responses, :embedding, using: :ivfflat, name: 'vector_idx_knowledge_entries_embedding', opclass: :vector_l2_ops
  end

  def create_old_tables
    create_table :article_embeddings, if_not_exists: true do |t|
      t.bigint :article_id, null: false
      t.text :term, null: false
      t.vector :embedding, limit: 1536
      t.timestamps
    end
    add_index :article_embeddings, :embedding, if_not_exists: true, using: :ivfflat, opclass: :vector_l2_ops
  end
end
