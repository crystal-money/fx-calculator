module FXCalculator
  module Utils
    extend self

    # Parses a string representing a money value along with target currency,
    # if present, and returns it as a tuple of `Money` and `Money::Currency`.
    def parse_money_with_currency(str : String) : {Money, Money::Currency}
      if match = str.match_full(/(?<amount>.*?)\s+(?:in|to)\s+(?<currency>\w+)/)
        {match["amount"].to_money, Money::Currency.find(match["currency"])}
      else
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
