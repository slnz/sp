# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "mail_safe"
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Myron Marston"]
  s.date = "2010-10-14"
  s.email = "myron.marston@gmail.com"
  s.extra_rdoc_files = ["LICENSE", "README.rdoc"]
  s.files = ["LICENSE", "README.rdoc"]
  s.homepage = "http://github.com/myronmarston/mail_safe"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.11"
  s.summary = "Keep your ActionMailer emails from escaping into the wild during development."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<actionmailer>, [">= 1.3.6"])
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
    else
      s.add_dependency(%q<actionmailer>, [">= 1.3.6"])
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
    end
  else
    s.add_dependency(%q<actionmailer>, [">= 1.3.6"])
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
  end
end
