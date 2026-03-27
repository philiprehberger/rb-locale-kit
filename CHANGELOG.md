# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-03-26

### Added
- Initial release
- BCP 47 language tag parsing (`LocaleKit.parse`)
- Content negotiation with fallback chains (`LocaleKit.negotiate`)
- HTTP Accept-Language header parsing (`LocaleKit.parse_accept_language`)
- Locale comparison, equality, and sorting
- Parent locale chain traversal
- Prefix matching support
