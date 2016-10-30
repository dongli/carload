class Product < ApplicationRecord
  mount_uploader :image, ImageUploader
  include Croppable

  has_many :items
  has_one :package, as: :packagable
  has_many :product_inventory_joins
  has_many :inventories, through: :product_inventory_joins
end
