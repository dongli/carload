module Carload
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def mount_routes
      return if File.read('config/routes.rb').include? 'mount Carload::Engine'
      inject_into_file 'config/routes.rb', after: "Rails.application.routes.draw do\n" do <<-RUBY
  mount Carload::Engine => '/carload'
      RUBY
      end
    end

    def add_require
      return if File.read('config/application.rb') =~ /require ['|"]carload['|"]/
      inject_into_file 'config/application.rb', after: "Bundler.require(*Rails.groups)\n" do <<-RUBY
require 'carload'
      RUBY
      end
    end

    def copy_initializer
      return if File.exist? 'config/initializers/carload.rb'
      copy_file 'carload.rb', 'config/initializers/carload.rb'
    end

    def copy_dashboard_file
      copy_file 'dashboard.rb', 'app/carload/dashboard.rb'
    end

    def copy_migration_files
      # Copy migrations if necessary.
      if (Carload.search_engine rescue nil) == :pg_search
        adapter = ActiveRecord::Base.connection.instance_values["config"][:adapter]
        if adapter != 'postgresql'
          raise InvalidError.new("Database adapter #{adapter} cannot work with pg_search!")
        end
        case I18n.locale
        when :'zh-CN'
          ['20161030074822_carload_enable_zhparser_extension.rb'].each do |file|
            copy_file "#{Carload::Engine.root}/db/migrate/#{file}", "db/migrate/#{file}"
          end
        end
      end
    end
  end
end
