# frozen_string_literal: true

require_relative "lib/simple_saml/version"

Gem::Specification.new do |spec|
  spec.name = "simple_saml"
  spec.version = SimpleSaml::VERSION
  spec.authors = ["Nkosi Khumalo"]
  spec.email = ["nkosik@amphora-research.com"]

  spec.summary = "Simple saml idp implementation"
  # spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage = "https://example.com"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://example.com"
  spec.metadata["changelog_uri"] = "https://example.com."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  spec.add_dependency('activesupport', '>= 5.2')
  spec.add_dependency('builder', '>= 3.0')
  spec.add_dependency('nokogiri', '>= 1.6.2')
  spec.add_dependency('xmldsig')
  spec.add_dependency('xmlenc', '>= 0.7.1')
  spec.add_dependency('httparty')

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
