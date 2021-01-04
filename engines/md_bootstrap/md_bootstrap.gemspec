
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "md_bootstrap/version"

Gem::Specification.new do |spec|
  spec.name          = "md_bootstrap"
  spec.version       = MDBootstrap::VERSION
  spec.authors       = ["Giang Nguyen"]
  spec.email         = ["giangnguyen1089@gmail.com"]

  spec.summary       = %q{Wrapper for MD Bootstrap}
  spec.description   = %q{Wrapper for MD Bootstrap}
  spec.homepage      = "https://shivyogportal.com/"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # SassC requires Ruby 2.3.3. Also specify here to make it obvious.
  spec.required_ruby_version = ">= 2.3.3"

  spec.add_runtime_dependency "sassc-rails", ">= 2.0.0"
  spec.add_runtime_dependency "autoprefixer-rails", ">= 9.1.0"

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
end
