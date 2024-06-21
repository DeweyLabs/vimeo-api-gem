lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "vimeo_api_client/version"

Gem::Specification.new do |spec|
  spec.name = "vimeo_api_client"
  spec.version = Vimeo::VERSION
  spec.authors = ["SergeyMell"]
  spec.email = ["sergey.mell@agilie.com"]

  spec.summary = "A Ruby wrapper for the Vimeo API"
  spec.description = "A Ruby wrapper for the Vimeo API"
  spec.homepage = "https://github.com/agilie/vimeo-api-gem"
  spec.license = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty"
  spec.add_dependency "hashie"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
