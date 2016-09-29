module Carload
  class Engine < ::Rails::Engine
    isolate_namespace Carload

    initializer :set_autoload_paths do |app|
      # Load dashboard.rb in app.
      Dir.glob("#{app.root}/app/carload/*.rb").each do |file|
        require_dependency file
      end
    end
  end
end
