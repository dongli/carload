module Carload
  class Dashboard
    class ModelSpec
      attr_accessor :default, :attributes, :index_page, :associated_models

      SkippedAttributes = [
        'id', 'created_at', 'updated_at',
        'encrypted_password', 'reset_password_token',
        'reset_password_sent_at', 'remember_created_at',
        'sign_in_count', 'current_sign_in_at',
        'last_sign_in_at', 'current_sign_in_ip',
        'last_sign_in_ip'
      ].freeze

      def self.foreign_key? attribute
        attribute =~ /_id$/
      end

      def foreign_key? attribute
        ModelSpec.foreign_key? attribute
      end

      def self.polymorphic? model_class, attribute
        return false unless foreign_key? attribute
        model_class.column_names.include? "#{attribute.to_s.gsub('_id', '')}_type"
      end

      def polymorphic? model_class, attribute
        ModelSpec.polymorphic? model_class, attribute
      end

      def initialize model_class = nil
        @default = false
        @attributes = ExtendedHash.new
        @index_page = ExtendedHash.new
        @index_page[:shows] = ExtendedHash.new
        @index_page[:searches] = ExtendedHash.new
        @associated_models = {}
        if model_class
          @attributes[:permitted] = model_class.column_names - SkippedAttributes
          @attributes[:permitted].each do |attribute|
            @index_page[:shows][:attributes] ||= []
            @index_page[:searches][:attributes] ||= []
            if foreign_key? attribute
              associated_model = attribute.gsub('_id', '')
              @associated_models[associated_model] = {
                choose_by: nil, # Wait for setting.
                polymorphic: polymorphic?(model_class, attribute),
                model: model_class.name.underscore.to_sym
              }
            else
              @index_page[:shows][:attributes] << attribute
              @index_page[:searches][:attributes] << { name: attribute.to_sym, term: :cont }
            end
          end
        end
      end

      def changed? spec
        not @attributes[:permitted] == spec.attributes[:permitted] or
        not @index_page[:searches][:attributes] == spec.index_page[:searches][:attributes]
      end

      def revise_stage_1!
        # Handle polymorphic associated models if necessary.
        @associated_models.each do |associated_model, options|
          next if not options or not options[:polymorphic]
          ActiveRecord::Base.descendants.each do |model|
            next if model.name == 'ApplicationRecord'
            if not model.reflect_on_all_associations.map(&:name).select { |x| x.to_s =~ /\b(#{options[:model]}|#{options[:model].to_s.pluralize})\b/ }.empty?
              options[:available_models] ||= []
              options[:available_models] << model.name.underscore
              if not options[:common_attributes]
                options[:common_attributes] = model.column_names - SkippedAttributes
              else
                options[:common_attributes] = options[:common_attributes] & model.column_names
              end
            end
          end
        end
      end

      def revise_stage_2!
        # Handle associated models if necessary.
        @associated_models.each do |associated_model, options|
          next if not options
          if options[:polymorphic]
            # There should be a <associated_model>_type already.
            @index_page[:shows][:attributes] << "#{associated_model}.#{options[:choose_by]}"
            @index_page[:searches][:attributes].each do |attribute|
              next unless attribute[:name] == :"#{associated_model}_type"
              attribute[:options] = options[:available_models]
            end
          else
            @index_page[:searches][:attributes] << {
              name: "#{associated_model}.#{options[:choose_by]}",
              term: :cont
            }
          end
        end
      end
    end

    class << self
      def model name, &block
        name = name.to_sym
        if block_given?
          @@models ||= {}
          spec = @@models[name] || ModelSpec.new
          yield spec
          @@models[name] = spec
        else
          @@models[name]
        end
      end

      def associate options
        model_a = options.keys.first
        model_b = options.values.first
        options.shift
        @@models[model_a] ||= ModelSpec.new
        @@models[model_a].associated_models[model_b] = options
        unless options[:polymorphic]
          @@models[model_b] ||= ModelSpec.new
          @@models[model_b].associated_models[model_a] = nil
        end
      end

      def models
        @@models ||= {}
      end

      def default_model
        return @@default_model if defined? @@default_model
        @@models.each do |name, spec|
          return @@default_model = name if spec.default
        end
        @@default_model = @@models.keys.first
      end

      def write file_path
        content = File.read("#{Carload::Engine.root}/lib/generators/carload/templates/dashboard.rb")
        content.gsub!(/^end$/, '')
        default = true
        models.each do |name, spec|
          content << <<-RUBY
  model :#{name} do |spec|
    spec.default = #{default}
    spec.attributes.permitted = #{spec.attributes.permitted}
    spec.index_page.shows.attributes = #{spec.index_page.shows.attributes}
    spec.index_page.searches.attributes = #{spec.index_page.searches.attributes}
  end
          RUBY
          default = false
          next if spec.associated_models.empty?
          spec.associated_models.each do |associated_model, options|
            next if not options.class == Hash or not options[:choose_by]
            content << <<-RUBY
  associate(#{{ name.to_sym => associated_model.to_sym }.merge options})
            RUBY
          end
        end
        content << "end\n"
        File.open('app/carload/dashboard.rb', 'w') do |file|
          file.write content
          file.close
        end
      end
    end
  end
end
