module Carload
  class InstallGenerator < Rails::Generators::Base
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
  end
end
