$:.push File.expand_path('../lib', __FILE__)
require "clockface/version"

Gem::Specification.new do |s|
  s.name        = 'clockface'
  s.version     = Clockface::VERSION
  s.authors     = ['Abhishek Chandrasekhar']
  s.email       = ['me@abhchand.me']
  s.homepage    = 'https://github.com/abhchand/clockface'
  s.summary     = 'A Configuration UI for the Clockwork gem'
  s.description = s.summary
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '~> 5.1.0'
  s.add_dependency 'clockwork', '~> 2.0', '>= 2.0.2'

  s.add_development_dependency 'pg'
  s.add_development_dependency 'rspec-rails'
end
