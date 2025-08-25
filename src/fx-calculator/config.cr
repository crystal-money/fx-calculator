module FXCalculator
  class Config
    include YAML::Serializable

    # Filepath to currency rates cache.
    CURRENCY_RATES_FILEPATH =
      Path[Dir.tempdir] / "fx-calculator" / ".cache" / "currency_rates.json"

    # Initializes currency rates cache.
    def self.init_currency_rates_cache! : Nil
      Dir.mkdir_p(CURRENCY_RATES_FILEPATH.dirname)
    end

    # Clears currency rates cache.
    def self.clear_currency_rates_cache! : Bool
      File.delete?(CURRENCY_RATES_FILEPATH)
    end

    # Currency rate store to use.
    @[YAML::Field(ignore: true)]
    property rate_store : Money::Currency::RateStore do
      if ttl = currency_rates_ttl
        Money::Currency::RateStore::File.new(
          filepath: CURRENCY_RATES_FILEPATH,
          ttl: ttl,
        )
      else
        Money::Currency::RateStore::Memory.new
      end
    end

    # Rate provider used for currency exchange.
    @[YAML::Field(converter: Money::Currency::RateProvider::Converter)]
    property! rate_provider : Money::Currency::RateProvider

    # Time to live (TTL) for currency rates, `nil` means no persistence.
    @[YAML::Field(converter: Time::Span::Converter)]
    property currency_rates_ttl : Time::Span?

    # Target currency.
    property currency : Money::Currency?

    private def after_initialize
      Config.init_currency_rates_cache!
    end
  end
end
