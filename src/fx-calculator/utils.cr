module FXCalculator
  module Utils
    extend self

    def config_from_opts(
      config_path : Path | String?,
      rate_store_name : String?,
      rate_store_opts : String?,
      rate_provider_name : String?,
      rate_provider_opts : String?,
      currency_code : String?,
      currency_rates_ttl : String?,
    )
      config =
        if config_path
          File.open(config_path) do |file|
            FXCalculator::Config.from_yaml(file)
          end
        else
          FXCalculator::Config.from_yaml("{}")
        end

      if rate_store_name
        config.rate_store = begin
          klass = Money::Currency::RateStore.find(rate_store_name)
          klass.from_json(rate_store_opts || "{}")
        end
      end

      if rate_provider_name
        config.rate_provider = begin
          klass = Money::Currency::RateProvider.find(rate_provider_name)
          klass.from_json(rate_provider_opts || "{}")
        end
      end

      if currency_code
        config.currency =
          Money::Currency.find(currency_code)
      end

      if currency_rates_ttl
        config.rate_store.ttl =
          Time::Span::StringConverter.parse(currency_rates_ttl)
      end

      unless config.rate_provider?
        raise ArgumentError.new("Currency rate provider is required")
      end

      config
    end

    # Parses a string representing a money value along with target currency,
    # if present, and returns it as a tuple of `Money` and `Money::Currency`.
    def parse_money_with_currency(str : String) : {Money, Money::Currency}
      case str
      when /^(?<base_currency>[a-zA-Z]\w+)\s+(?:in|to)\s+(?<target_currency>\w+)$/
        # BTC to USD
        {
          Money.from_amount(1, Money::Currency.find($~["base_currency"])),
          Money::Currency.find($~["target_currency"]),
        }
      when /^(?<amount>.*?)\s+(?:in|to)\s+(?<target_currency>\w+)$/
        # $100 to EUR
        {$~["amount"].to_money, Money::Currency.find($~["target_currency"])}
      else
        # $100
        {str.to_money, Money.default_currency}
      end
    end

    # Parses a string representing a money value along with target currency,
    # if present, and returns it as a tuple of a `Money` (original value) and
    # `Money` (exchanged to the target currency).
    def parse_money_exchanged(str : String) : {Money, Money}
      money, currency = parse_money_with_currency(str)
      {
        money,
        money.exchange_to(currency),
      }
    end
  end
end
