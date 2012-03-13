# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "google-geocode"
  s.version = "1.2.1"

  s.required_rubygems_version = nil if s.respond_to? :required_rubygems_version=
  s.authors = ["Eric Hodel"]
  s.cert_chain = nil
  s.date = "2006-11-27"
  s.description = "Map addresses to latitude and longitude with Google's Geocoder."
  s.email = "drbrain@segment7.net"
  s.homepage = "http://dev.robotcoop.com/Libraries/google-geocode"
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new("> 0.0.0")
  s.rubyforge_project = "rctools"
  s.rubygems_version = "1.8.11"
  s.summary = "Google Geocoder API Library"

  if s.respond_to? :specification_version then
    s.specification_version = 1

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hoe>, [">= 1.1.4"])
      s.add_runtime_dependency(%q<rc-rest>, [">= 2.0.0"])
    else
      s.add_dependency(%q<hoe>, [">= 1.1.4"])
      s.add_dependency(%q<rc-rest>, [">= 2.0.0"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.1.4"])
    s.add_dependency(%q<rc-rest>, [">= 2.0.0"])
  end
end
