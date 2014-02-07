# frozen_string_literal: true

require_relative 'locale_kit/version'
require_relative 'locale_kit/locale'
require_relative 'locale_kit/accept_language'
require_relative 'locale_kit/negotiator'

module Philiprehberger
  module LocaleKit
    class Error < StandardError; end

    # BCP 47 tag pattern: language[-script][-region]
    # language: 2-3 alpha, script: 4 alpha, region: 2 alpha or 3 digit
    TAG_PATTERN = /\A
      (?<language>[a-zA-Z]{2,3})
      (?:-(?<script>[a-zA-Z]{4}))?
      (?:-(?<region>[a-zA-Z]{2}|\d{3}))?
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

      Locale.new(
        match[:language],
        script: match[:script],
        region: match[:region]
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
  end
end
