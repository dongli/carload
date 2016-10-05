class Item < ApplicationRecord
  mount_uploader :image, ImageUploader
  include Croppable

  belongs_to :product
  has_one :package, as: :packagable

  validates :name, uniqueness: true, presence: true
end
