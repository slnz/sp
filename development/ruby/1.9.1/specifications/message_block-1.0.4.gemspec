# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "message_block"
  s.version = "1.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.4") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben Hughes"]
  s.date = "2011-04-15"
  s.description = "Implements the common view pattern by which a list of messages are shown at the top, often a combination of flash messages and ActiveRecord validation issues on one or more models."
  s.email = "ben@railsgarden.com"
  s.homepage = "http://github.com/rubiety/message_block"
  s.require_paths = ["lib"]
  s.rubyforge_project = "message_block"
  s.rubygems_version = "1.8.11"
  s.summary = "Flash message and error_messages_for handling with a common interface."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, [">= 3.0.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.0"])
      s.add_development_dependency(%q<cucumber>, ["~> 0.9.2"])
      s.add_development_dependency(%q<capybara>, ["~> 0.3.9"])
      s.add_development_dependency(%q<sqlite3-ruby>, ["~> 1.3.1"])
    else
      s.add_dependency(%q<rails>, [">= 3.0.0"])
      s.add_dependency(%q<rspec>, ["~> 2.0"])
      s.add_dependency(%q<cucumber>, ["~> 0.9.2"])
      s.add_dependency(%q<capybara>, ["~> 0.3.9"])
      s.add_dependency(%q<sqlite3-ruby>, ["~> 1.3.1"])
    end
  else
    s.add_dependency(%q<rails>, [">= 3.0.0"])
    s.add_dependency(%q<rspec>, ["~> 2.0"])
    s.add_dependency(%q<cucumber>, ["~> 0.9.2"])
    s.add_dependency(%q<capybara>, ["~> 0.3.9"])
    s.add_dependency(%q<sqlite3-ruby>, ["~> 1.3.1"])
  end
end
