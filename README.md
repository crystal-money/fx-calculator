# FX-Calculator [![CI](https://github.com/crystal-money/fx-calculator/actions/workflows/ci.yml/badge.svg)](https://github.com/crystal-money/fx-calculator/actions/workflows/ci.yml) [![Releases](https://img.shields.io/github/release/crystal-money/fx-calculator.svg)](https://github.com/crystal-money/fx-calculator/releases) [![License](https://img.shields.io/github/license/crystal-money/fx-calculator.svg)](https://github.com/crystal-money/fx-calculator/blob/master/LICENSE)

Simple command line tool for calculating foreign exchange rates.

## Installation

```sh
git clone https://github.com/crystal-money/fx-calculator.git
cd fx-calculator

shards install
shards build --release
```

## Usage

> [!NOTE]
> Available rate providers can be found at <https://github.com/crystal-money/money/tree/master/src/money/currency/rate_provider>.

Get a currency exchange rate between `EUR` and `USD`,
using the `FloatRates` provider.

```sh
./bin/fx-calculator -p FloatRates 'EUR to USD'
```

Convert `200 USD` to `PLN` (by providing the currency inline),
using the `FloatRates` provider.

```sh
./bin/fx-calculator -p FloatRates '$200 in PLN'
./bin/fx-calculator -p FloatRates '$200 to PLN'
```

Convert `200 USD` and `430 EUR` to `PLN` (by setting the default currency),
using the `FloatRates` provider.

```sh
./bin/fx-calculator -p FloatRates -C PLN '$200' '430 EUR'
```

You can use a configuration file (`-c /path/to/config.yml`) instead of providing
options through the command line:

```yaml
currency: EUR

exchange:
  rate_store:
    name: File
    options:
      filepath: ~/.cache/fx-calculator/currency-rates.json
      ttl: 15 minutes

  rate_provider:
    name: Compound
    options:
      providers:
        - name: FloatRates
        - name: UniRateAPI
          options:
            api_key: your-api-key
```

To see all available options run `./bin/fx-calculator --help`.

## Contributing

1. Fork it (<https://github.com/crystal-money/fx-calculator/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Sijawusz Pur Rahnama](https://github.com/Sija) - creator and maintainer
