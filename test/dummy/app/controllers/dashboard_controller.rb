class DashboardController < ApplicationController
  DEFAULT_MODEL = :product
  MODELS = [ :product, :item ]
  PERMITTED_ATTRIBUTES = {
    product: [ :name ],
    item: [ :name, :product_id ]
  }.freeze
  SHOW_ATTRIBUTES_ON_INDEX = {
    product: [ :name ],
    item: [ :name, 'product.name' ]
  }
  ASSOCIATIONS = {
    item: { product: :name }
  }
  SEARCH_ATTRIBUTES_ON_INDEX = {
    product: { name: :cont },
    item: { name: :cont }
  }
end
