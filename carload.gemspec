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
  s.description = 'Another Rails administration dashboard gem.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '~> 5.0.0', '>= 5.0.0.1'

  s.add_development_dependency 'sqlite3'
end
