require "colorize"

module FXCalculator
  class Renderer
    TEMPLATE =
      "%{base} = %{target} │ %{base_currency} to %{target_currency}"

    def initialize(@io = STDOUT)
    end

    def render(moneys : Enumerable({Money, Money})) : Nil
      moneys = moneys.map do |pair|
        {pair, pair.map(&.format(no_cents_if_whole: true))}
      end

      base_width =
        moneys.max_of(&.[1][0].size)

      target_width =
        moneys.max_of(&.[1][1].size)

      moneys.each do |(base, target), (base_formatted, target_formatted)|
        @io.puts TEMPLATE % {
          base:            base_formatted.ljust(base_width).colorize(:green),
          base_currency:   base.currency.colorize(:yellow),
          target:          target_formatted.rjust(target_width).colorize(:green),
          target_currency: target.currency.colorize(:yellow),
        }
      end
    end
  end
end
