module Carload
  class DashboardGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def copy_dashboard_file
      copy_file 'dashboard.rb', 'app/carload/dashboard.rb'
    end
  end
end
