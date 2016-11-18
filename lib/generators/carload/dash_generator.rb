module Carload
  class DashGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def change_dashboard_file
      # It is necessary to load models manually.
      Rails.application.eager_load!
      # Process model once atime.
      model_specs = {}
      ActiveRecord::Base.descendants.each do |model| # Rails 5 can use ApplicationRecord.
        next if model.name == 'ApplicationRecord' or model.name == 'PgSearch::Document'
        model_specs[model.name.underscore.to_sym] = ModelSpec.new model
      end
      model_name = file_name.to_sym
      spec = model_specs[model_name]
      if not spec.associations.empty?
        cli = HighLine.new
        spec.associations.each do |name, association|
          next if association[:filtered]
          reflection = association[:reflection]
          next if reflection.class ==
          if reflection.options[:polymorphic]
            attributes = association[:attributes]
          elsif reflection.options[:class_name]
            attributes = model_specs[reflection.options[:class_name].underscore.to_sym].attributes.permitted.select { |x| x.class != Hash }
          else
            attributes = model_specs[reflection.name.to_s.singularize.to_sym].attributes.permitted.select { |x| x.class != Hash }
          end
          if attributes.size == 1
            association[:choose_by] = attributes.first
          else
            association[:choose_by] = cli.choose do |menu|
              menu.prompt = "Choose the attribute of model #{reflection.name} for choosing in #{model_name}? "
              attributes.each do |attribute|
                next if attribute.to_s =~ /_id$/
                menu.choice attribute
              end
            end
          end
          # Change corresponding show attribute.
          spec.index_page[:shows][:attributes] = spec.index_page[:shows][:attributes].map do |attribute|
            if attribute.to_s =~ /#{name}/
              attribute = "#{name}.#{association[:choose_by]}"
            else
              attribute
            end
          end
        end
      end
      # Check if model exists in dashboard file, but it may be changed.
      if not Dashboard.models.keys.include? model_name or Dashboard.model(model_name).changed? spec
        Dashboard.models[model_name] = spec
        Dashboard.write 'app/carload/dashboard.rb'
      end
    end
  end
end
