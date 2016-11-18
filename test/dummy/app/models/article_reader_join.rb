class ArticleReaderJoin < ApplicationRecord
  belongs_to :article
  belongs_to :reader, class_name: 'User'
end
