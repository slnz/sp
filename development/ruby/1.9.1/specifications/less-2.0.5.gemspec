# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "less"
  s.version = "2.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Charles Lowell"]
  s.date = "2011-06-24"
  s.description = "Invoke the Less CSS compiler from Ruby"
  s.email = ["cowboyd@thefrontside.net"]
  s.executables = ["lessc"]
  s.files = ["bin/lessc"]
  s.homepage = "http://lesscss.org"
  s.require_paths = ["lib"]
  s.rubyforge_project = "less"
  s.rubygems_version = "1.8.11"
  s.summary = "Leaner CSS, in your browser or Ruby (via less.js)"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<therubyracer>, ["~> 0.9.2"])
      s.add_development_dependency(%q<rake>, ["~> 0.9.2"])
      s.add_development_dependency(%q<rspec>, ["~> 2.0"])
    else
      s.add_dependency(%q<therubyracer>, ["~> 0.9.2"])
      s.add_dependency(%q<rake>, ["~> 0.9.2"])
      s.add_dependency(%q<rspec>, ["~> 2.0"])
    end
  else
    s.add_dependency(%q<therubyracer>, ["~> 0.9.2"])
    s.add_dependency(%q<rake>, ["~> 0.9.2"])
    s.add_dependency(%q<rspec>, ["~> 2.0"])
  end
end
