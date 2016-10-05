module Carload
  class DashGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def change_dashboard_file
      # Process model once atime.
      model = file_name
      model_specs = {}
      Rails.application.eager_load! # It is necessary to load models manually.
      ActiveRecord::Base.descendants.each do |model| # Rails 5 can use ApplicationRecord.
        next if model.name == 'ApplicationRecord'
        name = model.name.underscore
        model_specs[name] = Dashboard::ModelSpec.new model
      end
      spec = model_specs[model]
      if not spec.associated_models.empty?
        spec.revise_stage_1!
        cli = HighLine.new
        cli.say "\nModel #{model} has associated with other models."
        spec.associated_models.each do |associated_model, options|
          spec.associated_models[associated_model][:choose_by] = cli.choose do |menu|
            menu.prompt = "Choose the attribute of model #{associated_model} for choosing in #{model}? "
            attributes = options[:polymorphic] ? options[:common_attributes] : model_specs[associated_model].attributes.permitted
            attributes.each do |attribute|
              next if attribute =~ /_id$/
              menu.choice attribute.to_sym
            end
          end
        end
        spec.revise_stage_2!
      end
      # Check if model exists in dashboard file, but it may be changed.
      begin
        load 'app/carload/dashboard.rb'
      rescue LoadError
        Dashboard.models[model.to_sym] = spec
        Dashboard.write 'app/carload/dashboard.rb'
      end
      if not Dashboard.models.keys.include? model.to_sym or Dashboard.model(model).changed? spec
        Dashboard.models[model.to_sym] = spec
        Dashboard.write 'app/carload/dashboard.rb'
      end
    end
  end
end
