module Carload
  class Engine < ::Rails::Engine
    isolate_namespace Carload

    initializer :set_autoload_paths do |app|
      # Load dashboard.rb in app.
      Dir.glob("#{app.root}/app/carload/*.rb").each do |file|
        require_dependency file
      end
    end

    config.after_initialize do
      # Fill up associations of models.
      Dashboard.models.each do |name, spec|
        spec.klass = name.to_s.camelize.constantize
        spec.klass.reflect_on_all_associations.each do |reflection|
          next unless spec.associations.has_key? reflection.name
          spec.associations[reflection.name][:reflection] = reflection
          # Record real class name.
          if reflection.options.has_key? :class_name
            spec.associations[reflection.name][:class_name] = reflection.options[:class_name].to_s.underscore.to_sym
          end
        end
        spec.process_associaitons
      end
      # Reopen model classes to add pg text search.
      case (Carload.search_engine rescue nil)
      when :elasticsearch
        Dashboard.models.each do |name, spec|
          spec.klass.class_eval do
            include Elasticsearch::Model
            include Elasticsearch::Model::Callbacks

            self.__elasticsearch__.client.indices.delete index: self.index_name rescue nil
            self.__elasticsearch__.client.indices.create \
              index: self.index_name,
              body: { settings: self.settings.to_hash, mappings: self.mappings.to_hash }
          end
          spec.klass.import rescue nil
        end
      when :pg_search
        Dictionaries = {
          en: 'english',
          :'zh-CN' => 'zhparser'
        }.freeze
        Dashboard.models.each do |name, spec|
          # NOTE: Only direct columns are included.
          attributes = spec.index_page.searches.attributes.select { |x| x[:name].class == Symbol }.map { |x| x[:name] }
          spec.klass.class_eval do
            include PgSearch
            pg_search_scope :search,
              against: attributes,
              using: {
                tsearch: {
                  prefix: true,
                  negation: true,
                  dictionary: Dictionaries[I18n.locale]
                }
              }
          end
        end
      end
      # Reopen model classes to handle polymorphic association.
      Dashboard.models.each do |name, spec|
        spec.associations.values.select { |x| x[:reflection].options[:polymorphic] }.each do |association|
          spec.klass.class_eval do
            class_eval <<-RUBY
              def self.#{association[:reflection].name.to_s.pluralize}
                polymorphic_objects = []
                #{association[:instance_models]}.each do |instance_model|
                  Dashboard.model(instance_model).klass.all.each do |object|
                    polymorphic_objects << ["\#{object.class} - \#{object.send(:#{association[:choose_by]})}", "\#{object.id},\#{object.class}"]
                  end
                end
                polymorphic_objects
              end
            RUBY
          end
        end
      end
    end
  end
end
