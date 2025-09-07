require "log"
require "option_parser"
require "colorize"
require "./fx-calculator"

Log.setup_from_env

clear_currency_rates_cache = false
config_path =
  if File.exists?(FXCalculator::Config::DEFAULT_CONFIG_PATH)
    FXCalculator::Config::DEFAULT_CONFIG_PATH
  end

currency_code = ENV["FX_CALCULATOR_CURRENCY"]?.presence
currency_rates_ttl = ENV["FX_CALCULATOR_CURRENCY_RATES_TTL"]?.presence

rate_provider_name = ENV["FX_CALCULATOR_RATE_PROVIDER"]?.presence
rate_provider_opts = ENV["FX_CALCULATOR_RATE_PROVIDER_OPTIONS"]?.presence

values = %w[]

option_parser = OptionParser.new do |parser|
  parser.banner = "Usage: fx-calculator [arguments]"

  parser.on("-x", "--clear-cache", "Clear currency rates cache") do
    clear_currency_rates_cache = true
  end
  parser.on("-c PATH", "--config=PATH", "Path to configuration file") do |path|
    config_path = Path[path] if path.presence
  end
  parser.on("-C CURRENCY", "--currency=CODE", "Default target currency") do |code|
    currency_code = code.presence
  end
  parser.on("-t TTL", "--currency-rates-ttl=TIME_SPAN", "Currency rates TTL") do |ttl|
    currency_rates_ttl = ttl.presence
  end
  parser.on("-p RATE_PROVIDER", "--provider=NAME", "Currency provider to use") do |name|
    rate_provider_name = name.presence
  end
  parser.on("-o RATE_PROVIDER_OPTIONS", "--provider-options=JSON", "Currency provider options") do |opts|
    rate_provider_opts = opts.presence
  end
  parser.on("-v", "--version", "Print version") do
    puts FXCalculator::VERSION
    exit(0)
  end
  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit(0)
  end
  parser.unknown_args do |args|
    values.concat(args)
  end
  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option".colorize(:red)
    STDERR.puts parser
    exit(1)
  end
end

option_parser.parse

begin
  if clear_currency_rates_cache
    FXCalculator::Config.clear_currency_rates_cache!
  end

  if values.empty?
    if clear_currency_rates_cache
      exit(0)
    else
      STDERR.puts option_parser
      exit(1)
    end
  end

  config =
    if path = config_path
      File.open(path) do |file|
        FXCalculator::Config.from_yaml(file)
      end
    else
      FXCalculator::Config.from_yaml("{}")
    end

  if code = currency_code
    config.currency = Money::Currency.find(code)
  end

  if name = rate_provider_name
    config.rate_provider = begin
      klass = Money::Currency::RateProvider.find(name)

      if opts = rate_provider_opts
        klass.from_json(opts)
      else
        klass.from_json("{}")
      end
    end
  end

  if ttl = currency_rates_ttl
    config.currency_rates_ttl = Time::Span.parse(ttl)
  end

  unless config.rate_provider?
    raise ArgumentError.new("Currency rate provider is required")
  end

  Money.configure do |context|
    context.default_currency = config.currency
    context.default_rate_store = config.rate_store
    context.default_rate_provider = config.rate_provider
  end

  moneys = values.map do |value|
    FXCalculator::Utils.parse_money_exchanged(value)
  end

  renderer = FXCalculator::Renderer.new
  renderer.render(moneys)
rescue ex
  STDERR.puts "ERROR: #{ex.message}".colorize(:red)
  exit(1)
end
