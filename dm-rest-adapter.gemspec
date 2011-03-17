# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-rest-adapter}
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Scott Burton @ Joyent Inc"]
  s.date = %q{2011-03-10}
  s.description = %q{REST Adapter for DataMapper}
  s.email = %q{scott.burton [a] joyent [d] com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    "Gemfile",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "dm-rest-adapter.gemspec",
    "lib/dm-rest-adapter.rb",
    "lib/dm-rest-adapter/adapter.rb",
    "lib/dm-rest-adapter/connection.rb",
    "lib/dm-rest-adapter/exceptions.rb",
    "lib/dm-rest-adapter/formats.rb",
    "lib/dm-rest-adapter/spec/setup.rb",
    "spec/fixtures/book.rb",
    "spec/fixtures/difficult_book.rb",
    "spec/rcov.opts",
    "spec/semipublic/connection_spec.rb",
    "spec/semipublic/rest_adapter_spec.rb",
    "spec/spec.opts",
    "spec/spec_helper.rb",
    "tasks/spec.rake",
    "tasks/yard.rake",
    "tasks/yardstick.rake"
  ]
  s.homepage = %q{http://github.com/datamapper/dm-rest-adapter}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{datamapper}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{REST Adapter for DataMapper}
  s.test_files = [
    "spec/fixtures/book.rb",
    "spec/fixtures/difficult_book.rb",
    "spec/semipublic/connection_spec.rb",
    "spec/semipublic/rest_adapter_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<dm-serializer>, ["~> 1.1.0"])
      s.add_development_dependency(%q<dm-validations>, ["~> 1.1.0"])
      s.add_development_dependency(%q<fakeweb>, ["~> 1.3"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<rake>, ["~> 0.8.7"])
      s.add_development_dependency(%q<rspec>, ["~> 1.3.1"])
    else
      s.add_dependency(%q<dm-serializer>, ["~> 1.1.0"])
      s.add_dependency(%q<dm-validations>, ["~> 1.1.0"])
      s.add_dependency(%q<fakeweb>, ["~> 1.3"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<rake>, ["~> 0.8.7"])
      s.add_dependency(%q<rspec>, ["~> 1.3.1"])
    end
  else
    s.add_dependency(%q<dm-serializer>, ["~> 1.1.0"])
    s.add_dependency(%q<dm-validations>, ["~> 1.1.0"])
    s.add_dependency(%q<fakeweb>, ["~> 1.3"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<rake>, ["~> 0.8.7"])
    s.add_dependency(%q<rspec>, ["~> 1.3.1"])
  end
end

