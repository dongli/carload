class Item < ApplicationRecord
  belongs_to :product

  validates :name, uniqueness: true, presence: true
end
