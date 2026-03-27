# frozen_string_literal: true

module Philiprehberger
  module LocaleKit
    # Represents a parsed BCP 47 language tag.
    #
    # Locale objects are immutable and comparable. A BCP 47 tag consists of:
    # - language: 2-3 character ISO 639 language code (required)
    # - script: 4 character ISO 15924 script code (optional)
    # - region: 2 alpha ISO 3166-1 or 3 digit UN M.49 code (optional)
    #
    # @example
    #   locale = Locale.new("en", region: "US")
    #   locale.to_s #=> "en-US"
    #   locale.parent #=> #<Locale language="en">
    class Locale
      include Comparable

      # @return [String] the language subtag (e.g., "en", "zh")
      attr_reader :language

      # @return [String, nil] the script subtag (e.g., "Hant", "Latn") or nil
      attr_reader :script

      # @return [String, nil] the region subtag (e.g., "US", "419") or nil
      attr_reader :region

      # Creates a new Locale instance.
      #
      # @param language [String] 2-3 character language subtag
      # @param script [String, nil] 4 character script subtag
      # @param region [String, nil] 2 alpha or 3 digit region subtag
      # @raise [ArgumentError] if language is invalid
      def initialize(language, script: nil, region: nil)
        validate_language!(language)
        validate_script!(script) if script
        validate_region!(region) if region

        @language = language.downcase.freeze
        @script = script&.then { |s| "#{s[0].upcase}#{s[1..].downcase}" }&.freeze
        @region = region&.upcase&.freeze
        freeze
      end

      # Returns the canonical BCP 47 string representation.
      #
      # @return [String] canonical tag (e.g., "en-US", "zh-Hant-TW")
      def to_s
        parts = [language]
        parts << script if script
        parts << region if region
        parts.join('-')
      end

      # Returns the parent locale by removing the most specific subtag.
      #
      # en-Latn-US -> en-Latn -> en -> nil
      #
      # @return [Locale, nil] the parent locale, or nil if this is a language-only locale
      def parent
        if region
          self.class.new(language, script: script)
        elsif script
          self.class.new(language)
        end
      end

      # Tests whether another locale is a prefix match of this locale.
      #
      # A locale matches if the other locale's subtags are a prefix of this locale's subtags.
      # For example, "en" matches "en-US" and "en-Latn-US".
      #
      # @param other [Locale, String] the locale to compare against
      # @return [Boolean] true if other is a prefix match
      def match?(other)
        other = LocaleKit.parse(other) if other.is_a?(String)

        return false unless language == other.language
        return true if other.script.nil? && other.region.nil?
        return false if other.script && script != other.script

        other.region.nil? || region == other.region
      end

      # Equality based on all subtag values.
      #
      # @param other [Object] object to compare
      # @return [Boolean]
      def ==(other)
        return false unless other.is_a?(Locale)

        language == other.language && script == other.script && region == other.region
      end

      alias eql? ==

      # @return [Integer] hash code based on all subtags
      def hash
        [language, script, region].hash
      end

      # Comparison for sorting. Orders by language, then script, then region.
      #
      # @param other [Locale] locale to compare
      # @return [Integer, nil] -1, 0, 1, or nil if not comparable
      def <=>(other)
        return nil unless other.is_a?(Locale)

        result = language <=> other.language
        return result unless result.zero?

        result = (script || '') <=> (other.script || '')
        return result unless result.zero?

        (region || '') <=> (other.region || '')
      end

      # @return [String] inspection string
      def inspect
        "#<#{self.class} #{self}>"
      end

      private

      def validate_language!(lang)
        raise ArgumentError, "language must be a 2-3 character string, got: #{lang.inspect}" unless
          lang.is_a?(String) && lang.match?(/\A[a-zA-Z]{2,3}\z/)
      end

      def validate_script!(scr)
        raise ArgumentError, "script must be a 4 character alphabetic string, got: #{scr.inspect}" unless
          scr.is_a?(String) && scr.match?(/\A[a-zA-Z]{4}\z/)
      end

      def validate_region!(reg)
        raise ArgumentError, "region must be a 2 alpha or 3 digit string, got: #{reg.inspect}" unless
          reg.is_a?(String) && reg.match?(/\A([a-zA-Z]{2}|\d{3})\z/)
      end
    end
  end
end
