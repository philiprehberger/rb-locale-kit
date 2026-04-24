# frozen_string_literal: true

require_relative 'locale_kit/version'
require_relative 'locale_kit/data'
require_relative 'locale_kit/locale'
require_relative 'locale_kit/accept_language'
require_relative 'locale_kit/negotiator'

module Philiprehberger
  module LocaleKit
    class Error < StandardError; end

    # BCP 47 tag pattern: language[-script][-region][-variant][-extensions]
    # language: 2-3 alpha, script: 4 alpha, region: 2 alpha or 3 digit
    # variant: 5-8 alphanumeric, extensions: singleton-value pairs
    TAG_PATTERN = /\A
      (?<language>[a-zA-Z]{2,3})
      (?:-(?<script>[a-zA-Z]{4}))?
      (?:-(?<region>[a-zA-Z]{2}|\d{3}))?
      (?:-(?<variant>[a-zA-Z0-9]{5,8}))?
      (?<extensions>(?:-[a-zA-Z]-[a-zA-Z0-9]{2,}(?:-[a-zA-Z0-9]{2,})*)*)
    \z/x

    private_constant :TAG_PATTERN

    # Parses a BCP 47 language tag string into a Locale object.
    #
    # @param tag [String] a BCP 47 language tag (e.g., "en-US", "zh-Hant-TW")
    # @return [Locale] the parsed locale
    # @raise [ArgumentError] if the tag is not a valid BCP 47 tag
    def self.parse(tag)
      raise ArgumentError, "tag must be a String, got: #{tag.class}" unless tag.is_a?(String)

      match = TAG_PATTERN.match(tag.strip)
      raise ArgumentError, "invalid BCP 47 tag: #{tag.inspect}" unless match

      extensions = parse_extensions(match[:extensions])

      Locale.new(
        match[:language],
        script: match[:script],
        region: match[:region],
        variant: match[:variant],
        extensions: extensions
      )
    end

    # Negotiates the best matching locale from available options.
    #
    # @param requested [Array<String, Locale>] locales requested by the client
    # @param available [Array<String, Locale>] locales the server supports
    # @param default [String, Locale, nil] fallback locale if no match is found
    # @return [Locale, nil] the best match, the default, or nil
    def self.negotiate(requested, available, default: nil)
      Negotiator.negotiate(requested, available, default: default)
    end

    # Parses an HTTP Accept-Language header into locale/quality pairs.
    #
    # @param header [String] the Accept-Language header value
    # @return [Array<Hash>] sorted array of { locale:, quality: } hashes
    def self.parse_accept_language(header)
      AcceptLanguage.parse(header)
    end

    # Returns a hash of common ISO 639-1 language codes to English names.
    #
    # @return [Hash<String, String>] language code to name mapping
    def self.languages
      Data::LANGUAGES
    end

    # Look up the English name for an ISO 639-1 language code.
    #
    # Case-insensitive. Returns `nil` for unknown codes or non-String input.
    #
    # @param code [String] a 2-letter ISO 639-1 code (e.g. "en", "EN")
    # @return [String, nil] the English language name, or nil if unknown
    def self.language_name(code)
      return nil unless code.is_a?(String)

      Data::LANGUAGES[code.downcase]
    end

    # Returns a hash of common ISO 3166-1 alpha-2 region codes to English names.
    #
    # @return [Hash<String, String>] region code to name mapping
    def self.regions
      Data::REGIONS
    end

    # @api private
    def self.parse_extensions(ext_string)
      return {} if ext_string.nil? || ext_string.empty?

      result = {}
      # Remove leading dash, then split by singleton pattern
      parts = ext_string.sub(/\A-/, '').split(/-(?=[a-zA-Z]-)/)
      parts.each do |part|
        segments = part.split('-')
        next unless segments.length >= 2

        singleton = segments[0]
        next unless singleton.match?(/\A[a-zA-Z]\z/)

        value = segments[1..].join('-')
        result[singleton.downcase] = value.downcase
      end
      result
    end

    private_class_method :parse_extensions
  end
end
