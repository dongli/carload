# Require all dependencies (Rails does not do this for us in default).
Gem.loaded_specs['carload'].dependencies.each do |dependency|
  require dependency.name
end

require 'carload/dashboard'
require 'carload/engine'
require 'carload/exceptions'

module Carload
  # Your code goes here...
end
