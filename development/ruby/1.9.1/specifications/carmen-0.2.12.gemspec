# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "carmen"
  s.version = "0.2.12"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jim Benton"]
  s.date = "2012-01-06"
  s.description = "A collection of geographic country and state names for Ruby. Also includes replacements for Rails' country_select and state_select plugins"
  s.email = "jim@autonomousmachine.com"
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["README.rdoc"]
  s.homepage = "http://github.com/jim/carmen"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.11"
  s.summary = "A collection of geographic country and state names for Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<rails>, [">= 0"])
      s.add_development_dependency(%q<hanna>, [">= 0"])
    else
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<rails>, [">= 0"])
      s.add_dependency(%q<hanna>, [">= 0"])
    end
  else
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<rails>, [">= 0"])
    s.add_dependency(%q<hanna>, [">= 0"])
  end
end
