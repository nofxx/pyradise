# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{pyradise}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marcos Piccinini"]
  s.date = %q{2009-07-27}
  s.default_executable = %q{pyradise}
  s.email = %q{x@nofxx.com}
  s.executables = ["pyradise"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/pyradise",
     "lib/pyradise.rb",
     "lib/pyradise/product.rb",
     "lib/pyradise/stat.rb",
     "lib/stores.yml",
     "pyradise.gemspec",
     "script/console",
     "spec/pyradise/product_spec.rb",
     "spec/pyradise/stat_spec.rb",
     "spec/pyradise_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/nofxx/pyradise}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Paraguay gem!}
  s.test_files = [
    "spec/spec_helper.rb",
     "spec/pyradise_spec.rb",
     "spec/pyradise/stat_spec.rb",
     "spec/pyradise/product_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<dm-core>, [">= 0"])
      s.add_runtime_dependency(%q<do_sqlite3>, [">= 0"])
    else
      s.add_dependency(%q<dm-core>, [">= 0"])
      s.add_dependency(%q<do_sqlite3>, [">= 0"])
    end
  else
    s.add_dependency(%q<dm-core>, [">= 0"])
    s.add_dependency(%q<do_sqlite3>, [">= 0"])
  end
end
