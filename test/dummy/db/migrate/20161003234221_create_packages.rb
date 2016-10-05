class CreatePackages < ActiveRecord::Migration[5.0]
  def change
    create_table :packages do |t|
      t.string :name
      t.references :packagable, polymorphic: true

      t.timestamps
    end
  end
end
