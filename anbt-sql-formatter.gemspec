# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "anbt-sql-formatter/version"

Gem::Specification.new do |s|
  s.name        = "anbt-sql-formatter"
  s.version     = Anbt::Sql::Formatter::VERSION
  s.authors     = ["sonota88"]
  s.email       = ["yosiot8753@gmail.com"]
  s.homepage    = "https://github.com/sonota88/anbt-sql-formatter"
  s.summary     = %q{A tool for SQL formatting written in Ruby.}
  s.description = %q{A tool for SQL formatting written in Ruby. Ruby port of Blanco SQL Formatter.}

  s.rubyforge_project = "anbt-sql-formatter"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
