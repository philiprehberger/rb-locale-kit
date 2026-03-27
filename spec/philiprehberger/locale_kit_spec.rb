# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::LocaleKit do
  it 'has a version number' do
    expect(Philiprehberger::LocaleKit::VERSION).not_to be_nil
  end

  describe '.parse' do
    it 'parses a simple language tag' do
      locale = described_class.parse('en')
      expect(locale.language).to eq('en')
      expect(locale.script).to be_nil
      expect(locale.region).to be_nil
    end

    it 'parses a language-region tag' do
      locale = described_class.parse('en-US')
      expect(locale.language).to eq('en')
      expect(locale.region).to eq('US')
      expect(locale.script).to be_nil
    end

    it 'parses a language-script-region tag' do
      locale = described_class.parse('zh-Hant-TW')
      expect(locale.language).to eq('zh')
      expect(locale.script).to eq('Hant')
      expect(locale.region).to eq('TW')
    end

    it 'parses a language-script tag' do
      locale = described_class.parse('zh-Hans')
      expect(locale.language).to eq('zh')
      expect(locale.script).to eq('Hans')
      expect(locale.region).to be_nil
    end

    it 'parses a three-letter language code' do
      locale = described_class.parse('yue')
      expect(locale.language).to eq('yue')
    end

    it 'parses a numeric region code' do
      locale = described_class.parse('es-419')
      expect(locale.language).to eq('es')
      expect(locale.region).to eq('419')
    end

    it 'normalizes case' do
      locale = described_class.parse('EN-us')
      expect(locale.language).to eq('en')
      expect(locale.region).to eq('US')
    end

    it 'normalizes script case' do
      locale = described_class.parse('zh-hANT-tw')
      expect(locale.script).to eq('Hant')
    end

    it 'strips whitespace' do
      locale = described_class.parse('  en-US  ')
      expect(locale.to_s).to eq('en-US')
    end

    it 'raises on empty string' do
      expect { described_class.parse('') }.to raise_error(ArgumentError)
    end

    it 'raises on invalid tag' do
      expect { described_class.parse('x') }.to raise_error(ArgumentError)
    end

    it 'raises on non-string input' do
      expect { described_class.parse(123) }.to raise_error(ArgumentError)
    end

    it 'raises on tag with invalid script length' do
      expect { described_class.parse('en-Lat') }.to raise_error(ArgumentError)
    end
  end

  describe Philiprehberger::LocaleKit::Locale do
    describe '#to_s' do
      it 'returns language only' do
        expect(described_class.new('en').to_s).to eq('en')
      end

      it 'returns language-region' do
        expect(described_class.new('en', region: 'US').to_s).to eq('en-US')
      end

      it 'returns language-script-region' do
        expect(described_class.new('zh', script: 'Hant', region: 'TW').to_s).to eq('zh-Hant-TW')
      end

      it 'returns language-script' do
        expect(described_class.new('zh', script: 'Hans').to_s).to eq('zh-Hans')
      end
    end

    describe '#parent' do
      it 'returns language-script from language-script-region' do
        locale = described_class.new('zh', script: 'Hant', region: 'TW')
        parent = locale.parent
        expect(parent.to_s).to eq('zh-Hant')
      end

      it 'returns language from language-script' do
        locale = described_class.new('zh', script: 'Hant')
        parent = locale.parent
        expect(parent.to_s).to eq('zh')
      end

      it 'returns language from language-region' do
        locale = described_class.new('en', region: 'US')
        parent = locale.parent
        expect(parent.to_s).to eq('en')
      end

      it 'returns nil from language only' do
        locale = described_class.new('en')
        expect(locale.parent).to be_nil
      end

      it 'walks the full parent chain' do
        locale = described_class.new('zh', script: 'Hant', region: 'TW')
        chain = []
        current = locale
        while (current = current.parent)
          chain << current.to_s
        end
        expect(chain).to eq(%w[zh-Hant zh])
      end
    end

    describe '#match?' do
      it 'matches exact locale' do
        locale = Philiprehberger::LocaleKit.parse('en-US')
        expect(locale.match?('en-US')).to be true
      end

      it 'matches language prefix' do
        locale = Philiprehberger::LocaleKit.parse('en-US')
        expect(locale.match?('en')).to be true
      end

      it 'does not match different language' do
        locale = Philiprehberger::LocaleKit.parse('en-US')
        expect(locale.match?('fr')).to be false
      end

      it 'does not match different region' do
        locale = Philiprehberger::LocaleKit.parse('en-US')
        expect(locale.match?('en-GB')).to be false
      end

      it 'matches script prefix' do
        locale = Philiprehberger::LocaleKit.parse('zh-Hant-TW')
        expect(locale.match?('zh-Hant')).to be true
      end

      it 'does not match different script' do
        locale = Philiprehberger::LocaleKit.parse('zh-Hant-TW')
        expect(locale.match?('zh-Hans')).to be false
      end
    end

    describe '#==' do
      it 'is equal for same subtags' do
        a = described_class.new('en', region: 'US')
        b = described_class.new('en', region: 'US')
        expect(a).to eq(b)
      end

      it 'is not equal for different regions' do
        a = described_class.new('en', region: 'US')
        b = described_class.new('en', region: 'GB')
        expect(a).not_to eq(b)
      end

      it 'is not equal for different types' do
        locale = described_class.new('en')
        expect(locale).not_to eq('en')
      end
    end

    describe '#<=>' do
      it 'sorts by language first' do
        locales = [
          Philiprehberger::LocaleKit.parse('zh'),
          Philiprehberger::LocaleKit.parse('en'),
          Philiprehberger::LocaleKit.parse('fr')
        ]
        expect(locales.sort.map(&:to_s)).to eq(%w[en fr zh])
      end

      it 'sorts by region within same language' do
        locales = [
          Philiprehberger::LocaleKit.parse('en-US'),
          Philiprehberger::LocaleKit.parse('en-GB'),
          Philiprehberger::LocaleKit.parse('en')
        ]
        expect(locales.sort.map(&:to_s)).to eq(%w[en en-GB en-US])
      end

      it 'returns nil for non-Locale comparison' do
        locale = described_class.new('en')
        expect(locale <=> 'en').to be_nil
      end
    end

    describe '#hash' do
      it 'produces equal hashes for equal locales' do
        a = described_class.new('en', region: 'US')
        b = described_class.new('en', region: 'US')
        expect(a.hash).to eq(b.hash)
      end

      it 'works as hash key' do
        a = described_class.new('en', region: 'US')
        b = described_class.new('en', region: 'US')
        hash = { a => 'value' }
        expect(hash[b]).to eq('value')
      end
    end

    describe 'immutability' do
      it 'is frozen' do
        locale = described_class.new('en', region: 'US')
        expect(locale).to be_frozen
      end
    end

    describe 'validation' do
      it 'raises on single char language' do
        expect { described_class.new('e') }.to raise_error(ArgumentError)
      end

      it 'raises on numeric language' do
        expect { described_class.new('12') }.to raise_error(ArgumentError)
      end

      it 'raises on invalid script length' do
        expect { described_class.new('en', script: 'La') }.to raise_error(ArgumentError)
      end

      it 'raises on invalid region' do
        expect { described_class.new('en', region: 'USA') }.to raise_error(ArgumentError)
      end

      it 'accepts 3-digit region' do
        locale = described_class.new('es', region: '419')
        expect(locale.region).to eq('419')
      end
    end
  end

  describe '.negotiate' do
    it 'returns exact match' do
      result = described_class.negotiate(%w[en-US], %w[en-US en-GB])
      expect(result.to_s).to eq('en-US')
    end

    it 'falls back to language match' do
      result = described_class.negotiate(%w[en-US], %w[en fr])
      expect(result.to_s).to eq('en')
    end

    it 'respects preference order' do
      result = described_class.negotiate(%w[fr en], %w[en fr])
      expect(result.to_s).to eq('fr')
    end

    it 'returns default when no match' do
      result = described_class.negotiate(%w[ja], %w[en fr], default: 'en')
      expect(result.to_s).to eq('en')
    end

    it 'returns nil when no match and no default' do
      result = described_class.negotiate(%w[ja], %w[en fr])
      expect(result).to be_nil
    end

    it 'handles empty requested' do
      result = described_class.negotiate([], %w[en fr], default: 'en')
      expect(result.to_s).to eq('en')
    end

    it 'handles empty available' do
      result = described_class.negotiate(%w[en], [], default: 'fr')
      expect(result.to_s).to eq('fr')
    end

    it 'handles script fallback' do
      result = described_class.negotiate(%w[zh-Hant-TW], %w[zh-Hant en])
      expect(result.to_s).to eq('zh-Hant')
    end

    it 'handles full fallback chain' do
      result = described_class.negotiate(%w[zh-Hant-TW], %w[zh en])
      expect(result.to_s).to eq('zh')
    end

    it 'accepts Locale objects' do
      requested = [Philiprehberger::LocaleKit.parse('en-US')]
      available = [Philiprehberger::LocaleKit.parse('en')]
      result = described_class.negotiate(requested, available)
      expect(result.to_s).to eq('en')
    end
  end

  describe '.parse_accept_language' do
    it 'parses a simple header' do
      result = described_class.parse_accept_language('en-US')
      expect(result.length).to eq(1)
      expect(result.first[:locale].to_s).to eq('en-US')
      expect(result.first[:quality]).to eq(1.0)
    end

    it 'parses multiple locales with quality' do
      result = described_class.parse_accept_language('en-US,en;q=0.9,fr;q=0.8')
      expect(result.length).to eq(3)
      expect(result[0][:locale].to_s).to eq('en-US')
      expect(result[0][:quality]).to eq(1.0)
      expect(result[1][:locale].to_s).to eq('en')
      expect(result[1][:quality]).to eq(0.9)
      expect(result[2][:locale].to_s).to eq('fr')
      expect(result[2][:quality]).to eq(0.8)
    end

    it 'sorts by quality descending' do
      result = described_class.parse_accept_language('fr;q=0.5,en;q=0.9')
      expect(result[0][:locale].to_s).to eq('en')
      expect(result[1][:locale].to_s).to eq('fr')
    end

    it 'handles wildcard' do
      result = described_class.parse_accept_language('en,*;q=0.1')
      expect(result.length).to eq(2)
      expect(result[1][:locale]).to be_nil
      expect(result[1][:quality]).to eq(0.1)
    end

    it 'handles spaces' do
      result = described_class.parse_accept_language('en-US , fr ; q=0.8')
      expect(result.length).to eq(2)
      expect(result[0][:locale].to_s).to eq('en-US')
      expect(result[1][:locale].to_s).to eq('fr')
    end

    it 'returns empty array for empty string' do
      result = described_class.parse_accept_language('')
      expect(result).to eq([])
    end

    it 'raises on non-string input' do
      expect { described_class.parse_accept_language(nil) }.to raise_error(ArgumentError)
    end

    it 'skips invalid entries' do
      result = described_class.parse_accept_language('en,x,fr')
      expect(result.length).to eq(2)
      expect(result.map { |e| e[:locale].to_s }).to eq(%w[en fr])
    end

    it 'clamps quality to 0-1 range' do
      result = described_class.parse_accept_language('en;q=1.5')
      expect(result.first[:quality]).to eq(1.0)
    end

    it 'parses complex real-world header' do
      header = 'zh-TW,zh;q=0.9,en-US;q=0.8,en;q=0.7'
      result = described_class.parse_accept_language(header)
      expect(result.map { |e| e[:locale].to_s }).to eq(%w[zh-TW zh en-US en])
    end
  end
end
