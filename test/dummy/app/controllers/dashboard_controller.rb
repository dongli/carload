class DashboardController < ApplicationController
  DEFAULT_MODEL = :item
  MODELS = [ :item ]
  PERMITTED_ATTRIBUTES = {
    item: [ :name ]
  }.freeze
  SHOW_ATTRIBUTES_ON_INDEX = {
    item: [ :name ]
  }
end
