class CreateArticles < ActiveRecord::Migration[5.0]
  def change
    create_table :articles do |t|
      t.references :author, class_name: 'User'
      t.string :title

      t.timestamps
    end
  end
end
