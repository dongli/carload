class Inventory < ApplicationRecord
  has_many :product_inventory_joins
  has_many :products, through: :product_inventory_joins
end
