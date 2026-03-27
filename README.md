# philiprehberger-locale_kit

[![Tests](https://github.com/philiprehberger/rb-locale-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-locale-kit/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-locale_kit.svg)](https://rubygems.org/gems/philiprehberger-locale_kit)
[![License](https://img.shields.io/github/license/philiprehberger/rb-locale-kit)](LICENSE)
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

# Simple language
en = Philiprehberger::LocaleKit.parse("en")

# Language + region
en_us = Philiprehberger::LocaleKit.parse("en-US")

# Language + script + region
zh_hant_tw = Philiprehberger::LocaleKit.parse("zh-Hant-TW")
zh_hant_tw.script #=> "Hant"

# Numeric region codes
es_latam = Philiprehberger::LocaleKit.parse("es-419")
```

### Parent Chain

```ruby
locale = Philiprehberger::LocaleKit.parse("zh-Hant-TW")
locale.parent.to_s        #=> "zh-Hant"
locale.parent.parent.to_s #=> "zh"
locale.parent.parent.parent #=> nil
```

### Locale Matching

```ruby
locale = Philiprehberger::LocaleKit.parse("en-US")
locale.match?("en")    #=> true
locale.match?("en-US") #=> true
locale.match?("en-GB") #=> false
locale.match?("fr")    #=> false
```

### Content Negotiation

```ruby
# Find the best match from available locales
result = Philiprehberger::LocaleKit.negotiate(
  ["en-US", "fr"],          # requested by client
  ["en", "fr", "de"],       # available on server
  default: "en"
)
result.to_s #=> "en"

# Falls back through parent chain: en-US -> en
result = Philiprehberger::LocaleKit.negotiate(["en-US"], ["en", "fr"])
result.to_s #=> "en"

# Returns default when no match found
result = Philiprehberger::LocaleKit.negotiate(["ja"], ["en", "fr"], default: "en")
result.to_s #=> "en"
```

### Accept-Language Header Parsing

```ruby
entries = Philiprehberger::LocaleKit.parse_accept_language(
  "en-US,en;q=0.9,zh-Hant;q=0.8,*;q=0.1"
)
entries[0][:locale].to_s #=> "en-US"
entries[0][:quality]     #=> 1.0
entries[1][:locale].to_s #=> "en"
entries[1][:quality]     #=> 0.9
```

## API

### `Philiprehberger::LocaleKit`

| Method | Description |
|--------|-------------|
| `.parse(tag)` | Parse a BCP 47 tag string into a `Locale` object |
| `.negotiate(requested, available, default: nil)` | Find the best matching locale with fallback chains |
| `.parse_accept_language(header)` | Parse an Accept-Language header into `[{locale:, quality:}]` |

### `Philiprehberger::LocaleKit::Locale`

| Method | Description |
|--------|-------------|
| `#language` | Language subtag (e.g., `"en"`) |
| `#script` | Script subtag (e.g., `"Hant"`) or `nil` |
| `#region` | Region subtag (e.g., `"US"`) or `nil` |
| `#to_s` | Canonical BCP 47 string (e.g., `"en-US"`) |
| `#parent` | Parent locale (`en-US` -> `en` -> `nil`) |
| `#match?(other)` | True if other is a prefix match |
| `#==(other)` | Equality based on all subtags |
| `#<=>(other)` | Comparison for sorting |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

[MIT](LICENSE)
