# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "excelsior"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matthew Mongeau"]
  s.date = "2010-01-04"
  s.description = "A Ruby gem that uses C bindings to read CSV files superfast. I'm totally serial!"
  s.email = "matt@toastyapps.com"
  s.extensions = ["ext/excelsior_reader/extconf.rb"]
  s.files = ["ext/excelsior_reader/extconf.rb"]
  s.homepage = "http://github.com/toastyapps/excelsior"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.11"
  s.summary = "A Ruby gem that uses C bindings to read CSV files superfast. I'm totally serial!"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
