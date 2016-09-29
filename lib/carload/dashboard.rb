module Carload
  class Dashboard
    class ModelSpec
      attr_accessor :default, :attributes, :index_page, :associated_models

      def initialize
        @default = false
        @attributes = ExtendedHash.new
        @index_page = ExtendedHash.new
        @index_page[:shows] = ExtendedHash.new
        @index_page[:searches] = ExtendedHash.new
        @associated_models = {}
      end
    end

    class << self
      def model name, &block
        if block_given?
          @@models ||= {}
          spec = ModelSpec.new
          yield spec
          @@models[name] = spec
        else
          @@models[name]
        end
      end

      def associate args
        model_a = args.keys.first
        model_b = args.values.first
        @@models[model_a].associated_models[model_b] = args[:choose_by]
        @@models[model_b].associated_models[model_a] = nil
      end

      def models
        @@models ||= {}
      end

      def default_model
        return @@default_model if defined? @@default_model
        @@models.each do |name, spec|
          return @@default_model = name if spec.default
        end
      end
    end
  end
end
