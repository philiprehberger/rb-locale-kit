# philiprehberger-locale_kit

[![Tests](https://github.com/philiprehberger/rb-locale-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-locale-kit/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-locale_kit.svg)](https://rubygems.org/gems/philiprehberger-locale_kit)
[![GitHub release](https://img.shields.io/github/v/release/philiprehberger/rb-locale-kit)](https://github.com/philiprehberger/rb-locale-kit/releases)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-locale-kit)](https://github.com/philiprehberger/rb-locale-kit/commits/main)
[![License](https://img.shields.io/github/license/philiprehberger/rb-locale-kit)](LICENSE)
[![Bug Reports](https://img.shields.io/github/issues/philiprehberger/rb-locale-kit/bug)](https://github.com/philiprehberger/rb-locale-kit/issues?q=is%3Aissue+is%3Aopen+label%3Abug)
[![Feature Requests](https://img.shields.io/github/issues/philiprehberger/rb-locale-kit/enhancement)](https://github.com/philiprehberger/rb-locale-kit/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)
[![Sponsor](https://img.shields.io/badge/sponsor-GitHub%20Sponsors-ec6cb9)](https://github.com/sponsors/philiprehberger)

BCP 47 locale parsing, matching, and content negotiation

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-locale_kit"
```

Or install directly:

```bash
gem install philiprehberger-locale_kit
```

## Usage

```ruby
require "philiprehberger/locale_kit"

locale = Philiprehberger::LocaleKit.parse("en-US")
locale.language #=> "en"
locale.region   #=> "US"
locale.to_s     #=> "en-US"
```

### Parsing BCP 47 Tags

```ruby
require "philiprehberger/locale_kit"

# Language + region
en_us = Philiprehberger::LocaleKit.parse("en-US")

# Language + script + region
zh_hant_tw = Philiprehberger::LocaleKit.parse("zh-Hant-TW")
zh_hant_tw.script #=> "Hant"

# Variant subtags
locale = Philiprehberger::LocaleKit.parse("en-US-valencia")
locale.variant #=> "valencia"

# Unicode extensions
locale = Philiprehberger::LocaleKit.parse("en-u-ca-buddhist")
locale.extensions #=> { "u" => "ca-buddhist" }
```

### Display Names

```ruby
require "philiprehberger/locale_kit"

Philiprehberger::LocaleKit.parse("en-US").display_name  #=> "English (United States)"
Philiprehberger::LocaleKit.parse("ja-JP").display_name   #=> "Japanese (Japan)"
Philiprehberger::LocaleKit.parse("zh-CN").display_name   #=> "Chinese (China)"
Philiprehberger::LocaleKit.parse("fr").display_name       #=> "French"
```

### Language Families

```ruby
require "philiprehberger/locale_kit"

Philiprehberger::LocaleKit.parse("en").language_family  #=> :germanic
Philiprehberger::LocaleKit.parse("fr").language_family  #=> :romance
Philiprehberger::LocaleKit.parse("ru").language_family  #=> :slavic
Philiprehberger::LocaleKit.parse("zh").language_family  #=> :sino_tibetan
Philiprehberger::LocaleKit.parse("ja").language_family  #=> :japonic
Philiprehberger::LocaleKit.parse("ko").language_family  #=> :koreanic
Philiprehberger::LocaleKit.parse("ar").language_family  #=> :semitic
```

### Language and Region Lookups

```ruby
require "philiprehberger/locale_kit"

Philiprehberger::LocaleKit.languages["en"]  #=> "English"
Philiprehberger::LocaleKit.languages["ja"]  #=> "Japanese"

Philiprehberger::LocaleKit.regions["US"]  #=> "United States"
Philiprehberger::LocaleKit.regions["JP"]  #=> "Japan"
```

### Content Negotiation

```ruby
require "philiprehberger/locale_kit"

result = Philiprehberger::LocaleKit.negotiate(
  ["en-US", "fr"],          # requested by client
  ["en", "fr", "de"],       # available on server
  default: "en"
)
result.to_s #=> "en"
```

### Accept-Language Header Parsing

```ruby
require "philiprehberger/locale_kit"

entries = Philiprehberger::LocaleKit.parse_accept_language(
  "en-US,en;q=0.9,zh-Hant;q=0.8,*;q=0.1"
)
entries[0][:locale].to_s #=> "en-US"
entries[0][:quality]     #=> 1.0
```

## API

### `Philiprehberger::LocaleKit`

| Method | Description |
|--------|-------------|
| `.parse(tag)` | Parse a BCP 47 tag string into a `Locale` object |
| `.negotiate(requested, available, default: nil)` | Find the best matching locale with fallback chains |
| `.parse_accept_language(header)` | Parse an Accept-Language header into `[{locale:, quality:}]` |
| `.languages` | Hash of ISO 639-1 language codes to English names |
| `.regions` | Hash of ISO 3166-1 alpha-2 region codes to English names |

### `Philiprehberger::LocaleKit::Locale`

| Method | Description |
|--------|-------------|
| `#language` | Language subtag (e.g., `"en"`) |
| `#script` | Script subtag (e.g., `"Hant"`) or `nil` |
| `#region` | Region subtag (e.g., `"US"`) or `nil` |
| `#variant` | Variant subtag (e.g., `"valencia"`) or `nil` |
| `#extensions` | Extension subtags hash (e.g., `{ "u" => "ca-buddhist" }`) |
| `#to_s` | Canonical BCP 47 string (e.g., `"en-US"`) |
| `#parent` | Parent locale (`en-US` -> `en` -> `nil`) |
| `#match?(other)` | True if other is a prefix match |
| `#display_name(in_locale: nil)` | Human-readable name (e.g., `"English (United States)"`) |
| `#language_family` | Language family symbol (e.g., `:germanic`) |
| `#==(other)` | Equality based on all subtags |
| `#<=>(other)` | Comparison for sorting |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this package useful, consider giving it a star on GitHub — it helps motivate continued maintenance and development.

[![LinkedIn](https://img.shields.io/badge/Philip%20Rehberger-LinkedIn-0A66C2?logo=linkedin)](https://www.linkedin.com/in/philiprehberger)
[![More packages](https://img.shields.io/badge/more-open%20source%20packages-blue)](https://philiprehberger.com/open-source-packages)

## License

[MIT](LICENSE)
