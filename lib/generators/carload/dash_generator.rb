def foreign_key? column
  column =~ /_id$/
end

module Carload
  class DashGenerator < Rails::Generators::NamedBase
    def change_dashboard_file
      model = file_name
      skipped_columns = [
        'id', 'created_at', 'updated_at',
        'encrypted_password', 'reset_password_token',
        'reset_password_sent_at', 'remember_created_at',
        'sign_in_count', 'current_sign_in_at',
        'last_sign_in_at', 'current_sign_in_ip',
        'last_sign_in_ip'
      ].freeze
      model_specs = {}
      Rails.application.eager_load!
      ActiveRecord::Base.descendants.each do |model|
        next if model.name == 'ApplicationRecord'
        columns = model.column_names - skipped_columns
        associated_models = {}
        columns.each do |column|
          associated_models[column.gsub('_id', '')] = {} if foreign_key? column
        end
        model_specs[model.name.underscore] = {
          columns: columns,
          associated_models: associated_models
        }
      end
      if not model_specs[name][:associated_models].empty?
        cli = HighLine.new
        cli.say "\nModel #{model} has associated with other models."
        model_specs[model][:associated_models].each do |associated_model, options|
          foreign_column = cli.choose do |menu|
            menu.prompt = "Choose foreign column for model #{associated_model} in #{model}? "
            model_specs[associated_model][:columns].each do |column|
              next if foreign_key? column
              menu.choice column.to_sym
            end
          end
          model_specs[model][:associated_models][associated_model][:foreign_column] = foreign_column
        end
      end
      pp model_specs
      content = ''
      spec = model_specs[model]
      searched_attributes = []
      spec[:columns].each do |column|
        next if foreign_key? column
        searched_attributes << { name: column, term: :cont }
      end
      spec[:associated_models].each do |associated_model, options|
        searched_attributes << { model: "#{associated_model.underscore}.#{options[:foreign_column]}", term: :cont }
      end
      content << <<-RUBY
  model :#{model.underscore} do |spec|
    spec.default = false
    spec.attributes.permitted = #{spec[:columns]}
    spec.index_page.shows.attributes = #{
      spec[:columns].map do |column|
        if foreign_key? column
          associated_model = column.gsub('_id', '')
          "#{associated_model}.#{spec[:associated_models][associated_model][:foreign_column]}"
        else
          column
        end
      end
    }
    spec.index_page.searches.attributes = #{searched_attributes}
  end
      RUBY
      if not spec[:associated_models].empty?
        spec[:associated_models].each do |associated_model, options|
          content << <<-RUBY
  associate :#{model.underscore} => :#{associated_model.underscore}, choose_by: :#{options[:foreign_column]}
          RUBY
        end
      end
      inject_into_file 'app/carload/dashboard.rb', before: /^end$/ do content end
    end
  end
end
