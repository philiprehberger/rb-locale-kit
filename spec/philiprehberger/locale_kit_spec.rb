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

    context 'with variant subtags' do
      it 'parses a language-region-variant tag' do
        locale = described_class.parse('en-US-valencia')
        expect(locale.language).to eq('en')
        expect(locale.region).to eq('US')
        expect(locale.variant).to eq('valencia')
      end

      it 'parses a language-variant tag' do
        locale = described_class.parse('ca-valencia')
        expect(locale.language).to eq('ca')
        expect(locale.variant).to eq('valencia')
      end

      it 'normalizes variant to lowercase' do
        locale = described_class.parse('en-US-VALENCIA')
        expect(locale.variant).to eq('valencia')
      end

      it 'parses variant with digits' do
        locale = described_class.parse('sl-nedis1')
        expect(locale.variant).to eq('nedis1')
      end
    end

    context 'with extension subtags' do
      it 'parses a Unicode extension' do
        locale = described_class.parse('en-u-ca-buddhist')
        expect(locale.language).to eq('en')
        expect(locale.extensions).to eq({ 'u' => 'ca-buddhist' })
      end

      it 'parses extension with region' do
        locale = described_class.parse('en-US-u-ca-buddhist')
        expect(locale.language).to eq('en')
        expect(locale.region).to eq('US')
        expect(locale.extensions).to eq({ 'u' => 'ca-buddhist' })
      end

      it 'normalizes extension keys and values to lowercase' do
        locale = described_class.parse('en-U-CA-BUDDHIST')
        expect(locale.extensions).to eq({ 'u' => 'ca-buddhist' })
      end
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

      it 'returns language-region-variant' do
        expect(described_class.new('en', region: 'US', variant: 'valencia').to_s).to eq('en-US-valencia')
      end

      it 'returns language-variant' do
        expect(described_class.new('ca', variant: 'valencia').to_s).to eq('ca-valencia')
      end

      it 'returns tag with extensions' do
        locale = described_class.new('en', extensions: { 'u' => 'ca-buddhist' })
        expect(locale.to_s).to eq('en-u-ca-buddhist')
      end

      it 'returns tag with region and extensions' do
        locale = described_class.new('en', region: 'US', extensions: { 'u' => 'ca-buddhist' })
        expect(locale.to_s).to eq('en-US-u-ca-buddhist')
      end

      it 'returns tag with variant and extensions' do
        locale = described_class.new('en', region: 'US', variant: 'valencia', extensions: { 'u' => 'ca-buddhist' })
        expect(locale.to_s).to eq('en-US-valencia-u-ca-buddhist')
      end
    end

    describe '#variant' do
      it 'returns nil when no variant' do
        locale = described_class.new('en')
        expect(locale.variant).to be_nil
      end

      it 'returns the variant subtag' do
        locale = described_class.new('ca', variant: 'valencia')
        expect(locale.variant).to eq('valencia')
      end

      it 'normalizes variant to lowercase' do
        locale = described_class.new('en', variant: 'VALENCIA')
        expect(locale.variant).to eq('valencia')
      end

      it 'freezes the variant string' do
        locale = described_class.new('en', variant: 'valencia')
        expect(locale.variant).to be_frozen
      end
    end

    describe '#extensions' do
      it 'returns empty hash when no extensions' do
        locale = described_class.new('en')
        expect(locale.extensions).to eq({})
      end

      it 'returns the extension hash' do
        locale = described_class.new('en', extensions: { 'u' => 'ca-buddhist' })
        expect(locale.extensions).to eq({ 'u' => 'ca-buddhist' })
      end

      it 'normalizes extension keys to lowercase strings' do
        locale = described_class.new('en', extensions: { U: 'ca-buddhist' })
        expect(locale.extensions).to eq({ 'u' => 'ca-buddhist' })
      end

      it 'normalizes extension values to lowercase' do
        locale = described_class.new('en', extensions: { 'u' => 'CA-BUDDHIST' })
        expect(locale.extensions).to eq({ 'u' => 'ca-buddhist' })
      end

      it 'freezes the extensions hash' do
        locale = described_class.new('en', extensions: { 'u' => 'ca-buddhist' })
        expect(locale.extensions).to be_frozen
      end
    end

    describe '#display_name' do
      it 'returns English name for known language' do
        locale = described_class.new('en')
        expect(locale.display_name).to eq('English')
      end

      it 'returns name with region for known language and region' do
        locale = described_class.new('en', region: 'US')
        expect(locale.display_name).to eq('English (United States)')
      end

      it 'returns name with region for various locales' do
        expect(described_class.new('fr', region: 'FR').display_name).to eq('French (France)')
        expect(described_class.new('de', region: 'DE').display_name).to eq('German (Germany)')
        expect(described_class.new('ja', region: 'JP').display_name).to eq('Japanese (Japan)')
        expect(described_class.new('zh', region: 'CN').display_name).to eq('Chinese (China)')
        expect(described_class.new('ko', region: 'KR').display_name).to eq('Korean (South Korea)')
        expect(described_class.new('pt', region: 'BR').display_name).to eq('Portuguese (Brazil)')
        expect(described_class.new('es', region: 'MX').display_name).to eq('Spanish (Mexico)')
        expect(described_class.new('it', region: 'IT').display_name).to eq('Italian (Italy)')
        expect(described_class.new('ru', region: 'RU').display_name).to eq('Russian (Russia)')
        expect(described_class.new('ar', region: 'SA').display_name).to eq('Arabic (Saudi Arabia)')
      end

      it 'returns name with region for locales with common regions' do
        expect(described_class.new('en', region: 'GB').display_name).to eq('English (United Kingdom)')
        expect(described_class.new('en', region: 'AU').display_name).to eq('English (Australia)')
        expect(described_class.new('en', region: 'CA').display_name).to eq('English (Canada)')
        expect(described_class.new('en', region: 'IN').display_name).to eq('English (India)')
        expect(described_class.new('nl', region: 'NL').display_name).to eq('Dutch (Netherlands)')
        expect(described_class.new('sv', region: 'SE').display_name).to eq('Swedish (Sweden)')
      end

      it 'returns tag string for unknown language' do
        locale = described_class.new('xx', region: 'US')
        expect(locale.display_name).to eq('xx-US')
      end

      it 'returns language name only for unknown region' do
        locale = described_class.new('en', region: 'XX')
        expect(locale.display_name).to eq('English')
      end

      it 'includes variant in display name' do
        locale = described_class.new('ca', region: 'ES', variant: 'valencia')
        expect(locale.display_name).to eq('Catalan (Spain, Valencia)')
      end

      it 'accepts in_locale keyword argument' do
        locale = described_class.new('en', region: 'US')
        expect(locale.display_name(in_locale: nil)).to eq('English (United States)')
      end
    end

    describe '#language_family' do
      it 'returns :germanic for English' do
        expect(described_class.new('en').language_family).to eq(:germanic)
      end

      it 'returns :germanic for Germanic languages' do
        %w[en de nl sv no da af].each do |lang|
          expect(described_class.new(lang).language_family).to eq(:germanic)
        end
      end

      it 'returns :romance for Romance languages' do
        %w[fr es pt it ro ca].each do |lang|
          expect(described_class.new(lang).language_family).to eq(:romance)
        end
      end

      it 'returns :slavic for Slavic languages' do
        %w[ru pl cs uk bg hr sr].each do |lang|
          expect(described_class.new(lang).language_family).to eq(:slavic)
        end
      end

      it 'returns :sino_tibetan for Chinese' do
        expect(described_class.new('zh').language_family).to eq(:sino_tibetan)
      end

      it 'returns :japonic for Japanese' do
        expect(described_class.new('ja').language_family).to eq(:japonic)
      end

      it 'returns :koreanic for Korean' do
        expect(described_class.new('ko').language_family).to eq(:koreanic)
      end

      it 'returns :semitic for Arabic' do
        expect(described_class.new('ar').language_family).to eq(:semitic)
      end

      it 'returns :semitic for Hebrew' do
        expect(described_class.new('he').language_family).to eq(:semitic)
      end

      it 'returns :other for unknown languages' do
        expect(described_class.new('vi').language_family).to eq(:other)
        expect(described_class.new('th').language_family).to eq(:other)
        expect(described_class.new('hi').language_family).to eq(:other)
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

      it 'removes variant before region' do
        locale = described_class.new('en', region: 'US', variant: 'valencia')
        parent = locale.parent
        expect(parent.to_s).to eq('en-US')
        expect(parent.variant).to be_nil
      end

      it 'removes extensions before variant' do
        locale = described_class.new('en', region: 'US', extensions: { 'u' => 'ca-buddhist' })
        parent = locale.parent
        expect(parent.to_s).to eq('en-US')
        expect(parent.extensions).to eq({})
      end

      it 'walks the full chain with variant and extensions' do
        locale = described_class.new('en', region: 'US', variant: 'valencia', extensions: { 'u' => 'ca-buddhist' })
        chain = []
        current = locale
        while (current = current.parent)
          chain << current.to_s
        end
        expect(chain).to eq(%w[en-US-valencia en-US en])
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

      it 'is not equal when variants differ' do
        a = described_class.new('en', variant: 'valencia')
        b = described_class.new('en')
        expect(a).not_to eq(b)
      end

      it 'is not equal when extensions differ' do
        a = described_class.new('en', extensions: { 'u' => 'ca-buddhist' })
        b = described_class.new('en')
        expect(a).not_to eq(b)
      end

      it 'is equal when all subtags match including variant and extensions' do
        a = described_class.new('en', region: 'US', variant: 'valencia', extensions: { 'u' => 'ca-buddhist' })
        b = described_class.new('en', region: 'US', variant: 'valencia', extensions: { 'u' => 'ca-buddhist' })
        expect(a).to eq(b)
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

      it 'sorts by variant within same language-region' do
        a = described_class.new('en', region: 'US', variant: 'posix1')
        b = described_class.new('en', region: 'US', variant: 'valencia')
        c = described_class.new('en', region: 'US')
        expect([b, a, c].sort.map(&:to_s)).to eq(%w[en-US en-US-posix1 en-US-valencia])
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

      it 'includes variant and extensions in hash' do
        a = described_class.new('en', variant: 'valencia')
        b = described_class.new('en')
        expect(a.hash).not_to eq(b.hash)
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

      it 'raises on variant shorter than 5 characters' do
        expect { described_class.new('en', variant: 'abcd') }.to raise_error(ArgumentError)
      end

      it 'raises on variant longer than 8 characters' do
        expect { described_class.new('en', variant: 'abcdefghi') }.to raise_error(ArgumentError)
      end

      it 'raises on variant with special characters' do
        expect { described_class.new('en', variant: 'val-ia') }.to raise_error(ArgumentError)
      end

      it 'accepts valid 5-char variant' do
        locale = described_class.new('en', variant: 'posix')
        expect(locale.variant).to eq('posix')
      end

      it 'accepts valid 8-char variant' do
        locale = described_class.new('en', variant: 'abcde123')
        expect(locale.variant).to eq('abcde123')
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

  describe '.languages' do
    it 'returns a hash of language codes to names' do
      languages = described_class.languages
      expect(languages).to be_a(Hash)
      expect(languages['en']).to eq('English')
      expect(languages['fr']).to eq('French')
      expect(languages['de']).to eq('German')
      expect(languages['ja']).to eq('Japanese')
      expect(languages['zh']).to eq('Chinese')
      expect(languages['ko']).to eq('Korean')
      expect(languages['pt']).to eq('Portuguese')
      expect(languages['it']).to eq('Italian')
      expect(languages['ru']).to eq('Russian')
      expect(languages['ar']).to eq('Arabic')
      expect(languages['nl']).to eq('Dutch')
      expect(languages['sv']).to eq('Swedish')
      expect(languages['no']).to eq('Norwegian')
      expect(languages['da']).to eq('Danish')
      expect(languages['fi']).to eq('Finnish')
      expect(languages['pl']).to eq('Polish')
      expect(languages['es']).to eq('Spanish')
    end

    it 'returns a frozen hash' do
      expect(described_class.languages).to be_frozen
    end

    it 'contains at least 50 entries' do
      expect(described_class.languages.size).to be >= 50
    end
  end

  describe '.regions' do
    it 'returns a hash of region codes to names' do
      regions = described_class.regions
      expect(regions).to be_a(Hash)
      expect(regions['US']).to eq('United States')
      expect(regions['GB']).to eq('United Kingdom')
      expect(regions['DE']).to eq('Germany')
      expect(regions['FR']).to eq('France')
      expect(regions['JP']).to eq('Japan')
      expect(regions['CN']).to eq('China')
      expect(regions['KR']).to eq('South Korea')
      expect(regions['BR']).to eq('Brazil')
      expect(regions['CA']).to eq('Canada')
      expect(regions['AU']).to eq('Australia')
      expect(regions['IN']).to eq('India')
      expect(regions['MX']).to eq('Mexico')
      expect(regions['ES']).to eq('Spain')
      expect(regions['IT']).to eq('Italy')
      expect(regions['NL']).to eq('Netherlands')
      expect(regions['SE']).to eq('Sweden')
    end

    it 'returns a frozen hash' do
      expect(described_class.regions).to be_frozen
    end

    it 'contains at least 50 entries' do
      expect(described_class.regions.size).to be >= 50
    end
  end
end
