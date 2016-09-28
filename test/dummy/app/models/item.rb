class Item < ApplicationRecord
  validates :name, uniqueness: true, presence: true
end
