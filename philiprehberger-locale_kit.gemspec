# frozen_string_literal: true

require_relative 'lib/philiprehberger/locale_kit/version'

Gem::Specification.new do |spec|
  spec.name          = 'philiprehberger-locale_kit'
  spec.version       = Philiprehberger::LocaleKit::VERSION
  spec.authors       = ['Philip Rehberger']
  spec.email         = ['me@philiprehberger.com']
  spec.summary       = 'BCP 47 locale parsing, matching, and content negotiation'
  spec.description   = 'Parse BCP 47 language tags, negotiate content language from Accept-Language headers, ' \
                       'and match locales with fallback chains. Zero dependencies.'
  spec.homepage      = 'https://github.com/philiprehberger/rb-locale-kit'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'
  spec.metadata['homepage_uri']          = spec.homepage
  spec.metadata['source_code_uri']       = spec.homepage
  spec.metadata['changelog_uri']         = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['bug_tracker_uri']       = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
