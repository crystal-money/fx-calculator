module FXCalculator
  class Config
    include YAML::Serializable

    # Currency rate store to use.
    @[YAML::Field(converter: Money::Currency::RateStore::Converter)]
    property rate_store : Money::Currency::RateStore do
      Money.default_rate_store
    end

    # Rate provider used for currency exchange.
    @[YAML::Field(converter: Money::Currency::RateProvider::Converter)]
    property! rate_provider : Money::Currency::RateProvider

    # Target currency.
    property currency : Money::Currency?
  end
end
