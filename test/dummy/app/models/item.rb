class Item < ApplicationRecord
  mount_uploader :image, ImageUploader
  include Croppable

  belongs_to :product

  validates :name, uniqueness: true, presence: true
end
