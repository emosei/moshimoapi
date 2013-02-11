# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "moshimoapi/version"

Gem::Specification.new do |s|
  s.name        = "moshimoapi"
  s.version     = Moshimoapi::VERSION
  s.authors     = ["emosei"]
  s.email       = ["sei.emoto@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{もしもドロップシッピング用API}
  s.description = %q{もしもドロップシッピング用API}

  s.rubyforge_project = "moshimoapi"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_development_dependency "libxml-ruby"
end
