module Carload
  class DashGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def change_dashboard_file
      # Process model once atime.
      model = file_name
      model_specs = {}
      Rails.application.eager_load! # It is necessary to load models manually.
      ActiveRecord::Base.descendants.each do |model| # Rails 5 can use ApplicationRecord.
        next if model.name == 'ApplicationRecord' or model.name == 'PgSearch::Document'
        name = model.name.underscore
        model_specs[name] = ModelSpec.new model
      end
      spec = model_specs[model]
      if not spec.associated_models.empty?
        cli = HighLine.new
        spec.associated_models.each_value do |associated_model|
          next if associated_model[:attributes].empty?
          if associated_model[:polymorphic]
            attributes = associated_model[:attributes]
          else
            attributes = model_specs[associated_model[:name].to_s].attributes.permitted.select { |x| x.class != Hash }
          end
          if attributes.size == 1
            associated_model[:choose_by] = attributes.first
          else
            associated_model[:choose_by] = cli.choose do |menu|
              menu.prompt = "Choose the attribute of model #{associated_model[:name]} for choosing in #{model}? "
              attributes.each do |attribute|
                next if attribute.to_s =~ /_id$/
                menu.choice attribute
              end
            end
          end
        end
        spec.revise!
      end
      # Check if model exists in dashboard file, but it may be changed.
      if not Dashboard.models.keys.include? model.to_sym or Dashboard.model(model).changed? spec
        Dashboard.models[model.to_sym] = spec
        Dashboard.write 'app/carload/dashboard.rb'
      end
    end
  end
end
