module FXCalculator
  module Utils
    extend self

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
