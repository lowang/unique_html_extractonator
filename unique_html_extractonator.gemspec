# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'unique_html_extractonator/version'

Gem::Specification.new do |spec|
  spec.name          = "unique_html_extractonator"
  spec.version       = UniqueHtmlExtractonator::VERSION
  spec.authors       = ["Przemyslaw Wroblewski"]
  spec.email         = ["przemyslaw.wroblewski@gmail.com"]

  spec.summary       = %q{Extract unique content from HTML using reference_html for comparison}
  spec.description   = %q{Designed to extract only significant content from page with layout, skipping all common elements like header or footer.}
  spec.homepage      = "https://github.com/lowang/unique_html_extractonator"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'http://mygemserver.com'
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "cliver"
  spec.add_dependency "nokogiri"
  spec.add_dependency "activesupport"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
end
