# frozen_string_literal: true

# TODO: check the file
#
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'boundary/version'

Gem::Specification.new do |spec|
  spec.name = 'boundary'
  spec.version = Boundary::VERSION
  spec.authors = ['Evgenii Danilov']
  spec.email = ['evgenii_danilov@epam.com']

  spec.summary = 'The tool to enforce the boundaries between Ruby namespaces, by using public api (facade)'
  spec.description = spec.summary
  spec.homepage = 'https://github.com/evgeny-danilov/boundary'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  # spec.metadata["allowed_push_host"] = "Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'dry-configurable', '>=0.14'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
