# Require all dependencies (Rails does not do this for us in default).
Gem.loaded_specs['carload'].dependencies.each do |dependency|
  require dependency.name
end

require 'carload/extended_hash'
require 'carload/dashboard'
require 'carload/engine'
require 'carload/exceptions'

module Carload
  def self.setup &block
    @@config = ExtendedHash.new
    @@config[:dashboard] = ExtendedHash.new
    @@config[:dashboard][:permits_user] = ExtendedHash.new
    yield @@config
    if @@config[:auth_solution] != :devise
      raise UnsupportedError.new("authentication solution #{@@config[:auth_solution]}")
    end

    @@config.each do |key, value|
      define_singleton_method key do
        value
      end
    end
  end
end
