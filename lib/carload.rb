# Require all dependencies (Rails does not do this for us in default).
Gem.loaded_specs['carload'].dependencies.each do |dependency|
  begin
    require dependency.name
  rescue LoadError
    # For elasticsearch-model and elasticsearch-rails
    require dependency.name.gsub('-', '/')
  end
end

require 'carload/extended_hash'
require 'carload/model_spec'
require 'carload/dashboard'
require 'carload/engine'
require 'carload/exceptions'

module Carload
  def self.setup &block
    # Read in configuration.
    @@config = ExtendedHash.new
    @@config[:page] = ExtendedHash.new
    @@config[:dashboard] = ExtendedHash.new
    @@config[:dashboard][:permits_user] = ExtendedHash.new
    yield @@config
    if not [:devise, :none].include? @@config[:auth_solution]
      raise UnsupportedError.new("authentication solution #{@@config[:auth_solution]}")
    end
    if not [:carrierwave].include? @@config[:upload_solution]
      raise UnsupportedError.new("upload solution #{@@config[:upload_solution]}")
    end
    @@config[:search_engine] ||= :elasticsearch
    if not [:elasticsearch, :pg_search, :none].include? @@config[:search_engine]
      raise UnsupportedError.new("search engine #{@@config[:search_engine]}")
    end
    # Define configuation helpers.
    @@config.each do |key, value|
      define_singleton_method key do
        value
      end
    end
  end
end
