# cotcube-cftcsource

This gem provides a module containing a set of methods to download, maintain, provide and 
analyze the COT data issued by the CFTC. It is part of the Cotcube suite. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cotcube-cftcsource'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install cotcube-cftcsource

## Usage

### Configuration

The gem expects a configfile 'cftcsource.yml', located in '/etc/cotcube/' on linux platform and '/usr/local/etc/cotcube/' on FreeBSD. The location of the configfile can be overwritten by passing the according parameter to `init`.

Following parameters are currently supported (please let me know if something is missing): 

```yaml
data_path: 'path where the raw downloaded data is saved and other data is cached'
symbols_file: 'A file containing a CSV with supported symbols--if ommited, an example set from constants.rb is used'
headers_path: 'Where the CSV headers for cot data and signal sets are cached.'
default_lookback: 'the amount of weeks to be used for indicators in signal processing'
default_set: 'the name of the indicator set to be used (as saved in etc/cotcube/indicators-<default_set>.rb)
```

### constants.rb

Basically sets up 3 constants:

1. CFTC\_LINKS contains all URLs to download all zipped COT reports from cftc.gov
2. CFTC\_HEADERS provides lists of symbols serving as headers for the CSV-saved COT data.
3. CFTC\_SYMBOL\_EXAMPLES contains 2 sets of configuration data. Each set has the following structure:
  * id: The CFTC id of the future.
  * symbol: Some verbal, unambiguous short identifier for this future.
  * ticksize:
  * power: The leverage per tick.
  * months: The set of trading months.
  * bcf: A legacy constant, it is '1.0' in almost most cases.
  * reports: uppercase letters, signaling which reports are available for the futures (Legacy, Financial, Disaggregated and Cit)
  * name: 

### init.rb
### fetch and distribute

`CftcSource.fetch` downloads and unzips all COT-packages from CFTC.gov matching the :year parameter, defaulting to the current year.
Please see https://cftc.gov/MarketReports/CommitmentsofTraders/HistoricalCompressed/index.htm for which year parameters are available. 

`CftcSource.distribute` breaks down the packages into the separated ID based directory tree. 

NOTE: When building from scratch you should fetch and distribute all packages in proper annual order, as each run just updates data after the last available record.

### provide.rb

Returns the requested series of raw COT data for given either :symbol or :id. The parameter :subset currently filters for 'std\_count', a further implementation is pending. If :subset is set to false, the complete series is returned. 

### series.rb

Based on the data returned by CftcSource.provide and the given indicator set, a series is created, cached and returned. 

The default indicator simply calculates the net positions for pairs of `_long` and `_short`. Other indicator sets can be created. A simple example is in `etc/cotcube/indicators-example.rb`.  

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/donkeybridge/bitangent.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
