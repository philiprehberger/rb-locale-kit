# frozen_string_literal: true

module Philiprehberger
  module LocaleKit
    # Content negotiation for matching requested locales against available locales.
    #
    # Uses a fallback chain strategy: for each requested locale, tries the exact match first,
    # then walks up the parent chain (e.g., en-Latn-US -> en-Latn -> en) looking for matches
    # in the available set. Quality weights from Accept-Language parsing are respected.
    module Negotiator
      # Finds the best matching locale from available options.
      #
      # @param requested [Array<String, Locale>] locales requested by the client, in preference order
      # @param available [Array<String, Locale>] locales the server can provide
      # @param default [String, Locale, nil] fallback locale if no match found
      # @return [Locale, nil] the best matching locale, or the default, or nil
      def self.negotiate(requested, available, default: nil)
        requested_locales = normalize(requested)
        available_locales = normalize(available)

        return resolve_default(default) if requested_locales.empty? || available_locales.empty?

        best = find_best_match(requested_locales, available_locales)
        best || resolve_default(default)
      end

      # @api private
      def self.find_best_match(requested, available)
        requested.each do |req|
          match = try_match_with_fallback(req, available)
          return match if match
        end
        nil
      end

      # @api private
      def self.try_match_with_fallback(locale, available)
        # Try exact match first
        exact = available.find { |a| a == locale }
        return exact if exact

        # Try available locales that match the requested locale (requested is more specific)
        match = available.find { |a| locale.match?(a) }
        return match if match

        # Walk up parent chain
        parent = locale.parent
        parent ? try_match_with_fallback(parent, available) : nil
      end

      # @api private
      def self.normalize(locales)
        Array(locales).map { |l| l.is_a?(Locale) ? l : LocaleKit.parse(l) }
      end

      # @api private
      def self.resolve_default(default)
        return nil if default.nil?

        default.is_a?(Locale) ? default : LocaleKit.parse(default)
      end

      private_class_method :find_best_match, :try_match_with_fallback, :normalize, :resolve_default
    end
  end
end
