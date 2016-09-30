class AddImageToItemsAndProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :items, :image, :string
    add_column :products, :image, :string
  end
end
