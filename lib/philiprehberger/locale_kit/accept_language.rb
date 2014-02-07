# frozen_string_literal: true

module Philiprehberger
  module LocaleKit
    # Parses HTTP Accept-Language headers into structured locale/quality pairs.
    #
    # Handles the full Accept-Language syntax as defined in RFC 7231:
    #   Accept-Language: en-US,en;q=0.9,zh-Hant;q=0.8,*;q=0.1
    module AcceptLanguage
      # Parses an Accept-Language header string.
      #
      # @param header [String] the Accept-Language header value
      # @return [Array<Hash>] sorted array of { locale:, quality: } hashes,
      #   highest quality first. Wildcard (*) entries are included with locale: nil.
      # @raise [ArgumentError] if header is not a String
      def self.parse(header)
        raise ArgumentError, "header must be a String, got: #{header.class}" unless header.is_a?(String)

        return [] if header.strip.empty?

        entries = header.split(',').filter_map { |part| parse_entry(part.strip) }
        entries.sort_by { |e| [-e[:quality], entries.index(e)] }
      end

      # @api private
      def self.parse_entry(entry)
        return nil if entry.empty?

        parts = entry.split(';').map(&:strip)
        tag = parts.shift

        quality = 1.0
        parts.each do |param|
          if param.match?(/\Aq\s*=\s*/i)
            q_value = param.sub(/\Aq\s*=\s*/i, '').strip
            quality = parse_quality(q_value)
          end
        end

        locale = tag == '*' ? nil : LocaleKit.parse(tag)
        { locale: locale, quality: quality }
      rescue ArgumentError
        nil
      end

      # @api private
      def self.parse_quality(value)
        q = Float(value)
        q.clamp(0.0, 1.0)
      rescue ArgumentError, TypeError
        1.0
      end

      private_class_method :parse_entry, :parse_quality
    end
  end
end
