$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'carload/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'carload'
  s.version     = Carload::VERSION
  s.authors     = ['Li Dong']
  s.email       = ['dongli.init@gmail.com']
  s.homepage    = 'https://github.com/dongli/carload'
  s.summary     = 'Another Rails administration dashboard gem.'
  s.description = 'Carload is built with taste, and tries to be just right!'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '~> 5.0.0', '>= 5.0.0.1'
  s.add_dependency 'jquery-rails', '~> 4.2'
  s.add_dependency 'turbolinks', '~> 5'
  s.add_dependency 'sass-rails', '~> 5.0'
  s.add_dependency 'uglifier', '~> 3.0'
  s.add_dependency 'font-awesome-rails', '~> 4.6'
  s.add_dependency 'bootstrap-sass', '~> 3.3'
  s.add_dependency 'simple_form', '~> 3.3'
  s.add_dependency 'ransack', '~> 1.8'
  s.add_dependency 'kaminari', '~> 0.17'
  s.add_dependency 'pundit', '~> 1.1'
  s.add_dependency 'select2-rails', '~> 4.0'
end
