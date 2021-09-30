# frozen_string_literal: true

require_relative "lib/pg_partitioned/version"

Gem::Specification.new do |spec|
  spec.name          = "pg_partitioned"
  spec.version       = PgPartitioned::VERSION
  spec.authors       = ["Naman"]
  spec.email         = ["1977419+metalogical@users.noreply.github.com"]

  spec.summary       = "Support for Postgres partitioned tables in Rails migrations"
  spec.homepage      = "https://github.com/team-settle/pg_partitioned"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.4.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
