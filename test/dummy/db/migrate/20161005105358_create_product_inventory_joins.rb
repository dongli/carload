class CreateProductInventoryJoins < ActiveRecord::Migration[5.0]
  def change
    create_table :product_inventory_joins do |t|
      t.belongs_to :product, index: true
      t.belongs_to :inventory, index: true

      t.timestamps
    end
  end
end
