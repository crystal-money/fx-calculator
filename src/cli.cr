require "log"
require "option_parser"
require "colorize"
require "./fx-calculator"

DEFAULT_CONFIG_PATH =
  Path["~", ".config", "fx-calculator", "config.yml"].expand(home: true)

Log.setup_from_env

clear_rate_store = false
config_path =
  if File.exists?(DEFAULT_CONFIG_PATH)
    DEFAULT_CONFIG_PATH
  end

currency_code = ENV["FX_CALCULATOR_CURRENCY"]?.presence

rate_store_name = ENV["FX_CALCULATOR_RATE_STORE"]?.presence
rate_store_opts = ENV["FX_CALCULATOR_RATE_STORE_OPTIONS"]?.presence

rate_provider_name = ENV["FX_CALCULATOR_RATE_PROVIDER"]?.presence
rate_provider_opts = ENV["FX_CALCULATOR_RATE_PROVIDER_OPTIONS"]?.presence

values = %w[]

option_parser = OptionParser.new do |parser|
  parser.banner = "Usage: fx-calculator [arguments]"

  parser.on("-c PATH", "--config=PATH", "Path to configuration file") do |path|
    config_path = Path[path].expand(home: true) if path.presence
  end
  parser.on("-x", "--clear-cache", "Clear currency rates cache") do
    clear_rate_store = true
  end
  parser.on("-C CURRENCY", "--currency=CODE", "Default target currency") do |code|
    currency_code = code if code.presence
  end
  parser.on("-s RATE_STORE", "--rate-store=NAME", "Currency store to use") do |name|
    rate_store_name = name if name.presence
  end
  parser.on("-S RATE_STORE_OPTIONS", "--rate-store-options=JSON", "Currency store options") do |opts|
    rate_store_opts = opts if opts.presence
  end
  parser.on("-p RATE_PROVIDER", "--rate-provider=NAME", "Currency provider to use") do |name|
    rate_provider_name = name if name.presence
  end
  parser.on("-P RATE_PROVIDER_OPTIONS", "--rate-provider-options=JSON", "Currency provider options") do |opts|
    rate_provider_opts = opts if opts.presence
  end
  parser.on("-v", "--version", "Print version") do
    puts FXCalculator::VERSION
    exit(0)
  end
  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit(0)
  end
  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option".colorize(:red)
    STDERR.puts parser
    exit(1)
  end
  parser.unknown_args do |args|
    values.concat(args)
  end
end

option_parser.parse

if values.empty?
  abort option_parser
end

begin
  config = FXCalculator::Utils.config_from_opts(
    config_path,
    rate_store_name,
    rate_store_opts,
    rate_provider_name,
    rate_provider_opts,
    currency_code,
  )

  if clear_rate_store
    config.exchange.rate_store.clear
  end

  Money.configure do |context|
    context.default_currency = config.currency
    context.default_exchange = config.exchange
  end

  moneys = values.map do |value|
    FXCalculator::Utils.parse_money_exchanged(value)
  end

  renderer = FXCalculator::Renderer.new
  renderer.render(moneys)
rescue ex
  abort "ERROR: #{ex.message}".colorize(:red)
end
