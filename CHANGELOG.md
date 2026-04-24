# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0] - 2026-04-24

### Added
- `LocaleKit.language_name(code)` — look up the English name for an ISO 639-1 language code (case-insensitive); returns `nil` for unknown codes or non-String input

## [0.3.0] - 2026-04-15

### Added

- Language compatibility: `Locale#compatible?(other)` returns `true` when both locales share the same primary language subtag (case-insensitive), regardless of script, region, variant, or extensions. Accepts either a `Locale` instance or a BCP 47 tag string; returns `false` for unparseable strings or `nil`

## [0.2.1] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.2.0] - 2026-03-28

### Added

- Variant subtag support: parse and store variant subtags (e.g., `en-US-valencia`) with `Locale#variant` accessor
- Extension subtag support: parse Unicode extension subtags (e.g., `en-u-ca-buddhist`) with `Locale#extensions` returning a hash
- Display name: `Locale#display_name` returning human-readable name (e.g., "English (United States)")
- Language family: `Locale#language_family` returning family symbol (:germanic, :romance, :slavic, :sino_tibetan, :japonic, :koreanic, :semitic, :other)
- Language lookup: `LocaleKit.languages` returning hash of ISO 639-1 codes to English names
- Region lookup: `LocaleKit.regions` returning hash of ISO 3166-1 alpha-2 codes to English names
- GitHub issue templates (bug report, feature request)
- Dependabot configuration
- Pull request template

## [0.1.1] - 2026-03-26

### Added

- Add GitHub funding configuration

## [0.1.0] - 2026-03-26

### Added
- Initial release
- BCP 47 language tag parsing (`LocaleKit.parse`)
- Content negotiation with fallback chains (`LocaleKit.negotiate`)
- HTTP Accept-Language header parsing (`LocaleKit.parse_accept_language`)
- Locale comparison, equality, and sorting
- Parent locale chain traversal
- Prefix matching support
