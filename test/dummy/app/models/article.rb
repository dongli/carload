class Article < ApplicationRecord
  belongs_to :author, class_name: 'User'
  has_many :article_reader_joins
  has_many :readers, through: :article_reader_joins, class_name: 'User'
end
