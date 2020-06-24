Gem::Specification.new do |gem|
  gem.name        = 'ruby_git_issue'
  gem.version     = '1.1.1'
  gem.date        = '2020-05-11'
  gem.summary     = "Ruby Git Issue on exception generation"
  gem.description = "When rails throws excpetion, this gem will create issue and if project available, it will create project, assign developer and set tags if availabe"
  gem.authors     = ["Arpit Vaishnav"]
  gem.email       = 'arpitvaishnav@gmail.com'
  gem.files       = Dir["{app,config,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  gem.homepage    = 'https://github.com/HLth-care/ruby_git_issue'
  gem.license     = 'MIT'
  gem.add_runtime_dependency 'octokit' , '~> 4.18', '>= 4.18.0'
  gem.add_runtime_dependency 'json' , '~> 2.1', '>= 2.1.0'
end