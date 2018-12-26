
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "banacle/version"

Gem::Specification.new do |spec|
  spec.name          = "banacle"
  spec.version       = Banacle::VERSION
  spec.authors       = ["Takuya Kosugiyama"]
  spec.email         = ["re@itkq.jp"]

  spec.summary       = %q{Operate your NACL through Slack slash command.}
  spec.description   = %q{Operate your NACL through Slack slash command.}
  spec.homepage      = "https://github.com/itkq/banacle"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "sinatra"
  spec.add_dependency "unicorn"
end
