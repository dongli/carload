class Product < ApplicationRecord
  mount_uploader :image, ImageUploader
  include Croppable

  has_many :items
  has_one :package, as: :packagable
end
