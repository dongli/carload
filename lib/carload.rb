# Require all dependencies (Rails does not do this for us in default).
Gem.loaded_specs['carload'].dependencies.each do |dependency|
  require dependency.name
end

require 'carload/extended_hash'
require 'carload/association_pipelines'
require 'carload/model_spec'
require 'carload/dashboard'
require 'carload/engine'
require 'carload/exceptions'

module Carload
  def self.setup &block
    # Fill up associations of models.
    if ARGV.first =~ /s|serve|c|console|db|dbconsole/
      Dashboard.models.each do |name, spec|
        spec.klass = name.to_s.camelize.constantize
        spec.klass.reflect_on_all_associations.each do |association|
          spec.handle_association association
        end
      end
    end
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
    # Define configuation helpers.
    @@config.each do |key, value|
      define_singleton_method key do
        value
      end
    end
  end
end
