require_relative "lib/payments"
require_relative "lib/payments/version"

Gem::Specification.new do |spec|
  spec.name        = "payments"
  spec.version     = Payments::VERSION
  spec.authors     = ["Evgenii Danilov"]
  spec.email       = ["evgenii_danilov@epam.com"]
  spec.homepage    = "http://mygemserver.com"
  spec.summary     = "Summary of Payments."
  spec.description = "Description of Payments."

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]
  end

  # spec.add_dependency "rails", ">= 7.0.4.3"
end
