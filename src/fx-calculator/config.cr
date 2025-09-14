module FXCalculator
  class Config
    include YAML::Serializable

    # Currency exchange to use.
    property exchange : Money::Currency::Exchange do
      Money.default_exchange
    end

    # Target currency.
    property currency : Money::Currency?
  end
end
