class ProductInventoryJoin < ApplicationRecord
  belongs_to :product, dependent: :destroy
  belongs_to :inventory, dependent: :destroy
end
