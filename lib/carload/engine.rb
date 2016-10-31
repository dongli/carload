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
      Dictionaries = {
        en: 'english',
        :'zh-CN' => 'zhparser'
      }.freeze
      # Reopen model classes to add pg text search.
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
      # Reopen model classes to handle polymorphic association.
      Dashboard.models.each do |name, spec|
        spec.associated_models.values.select { |x| x[:polymorphic] == true }.each do |associated_model|
          polymorphic_objects = []
          associated_model[:instance_models].each do |instance_model|
            Dashboard.model(instance_model).klass.all.each do |object|
              polymorphic_objects << ["#{object.class} - #{object.send(associated_model[:choose_by])}", "#{object.id},#{object.class}"]
            end
          end
          spec.klass.class_eval do
            class_eval <<-RUBY
              def self.#{associated_model[:name].to_s.pluralize}
                #{polymorphic_objects}
              end
            RUBY
          end
        end
      end
    end
  end
end
