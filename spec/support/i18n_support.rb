module I18nSupport
  def self.included(base)
    base.class_eval do
      after do
        I18n.backend.reload! if @are_translations_mocked
      end
    end
  end

  def mock_translation(key, value, locale: I18n.locale)
    @are_translations_mocked = true

    nested = key.to_s.split(".").reverse.inject(value) { |acc, part| { part => acc } }
    I18n.backend.store_translations(locale, nested)
  end
end

RSpec.configure do |config|
  config.include I18nSupport
end
