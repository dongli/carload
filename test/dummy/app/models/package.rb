class Package < ApplicationRecord
  belongs_to :packagable, polymorphic: true
end
