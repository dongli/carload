class CreateArticleReaderJoins < ActiveRecord::Migration[5.0]
  def change
    create_table :article_reader_joins do |t|
      t.references :article
      t.references :reader, class_name: 'User'

      t.timestamps
    end
  end
end
