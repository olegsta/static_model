# frozen_string_literal: true

require_relative "lib/static_model/version"

Gem::Specification.new do |spec|
  spec.name = "static_model"
  spec.version = StaticModel::VERSION
  spec.authors = ["olehstarosvitskyi"]
  spec.email = ["olegstarosvitskyi@gmail.com"]

  spec.summary = "This gem helps to use all power ActiveRecord without creating database table."
  spec.description = "This gem helps to use all power ActiveRecord without creating database table."
  spec.required_ruby_version = ">= 2.6.0"

  spec.homepage      = "https://github.com/olegsta/static_model"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
