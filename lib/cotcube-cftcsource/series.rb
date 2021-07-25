# frozen_string_literal: true

module Cotcube
  module CftcSource

    #   - there will be configfile, containing the indicators
    # a call hence
    #   1. will try to load from the series directory
    #   2. will try to update the series already loaded (or starting from empty)
    #   3. provides the series (containing only the lookback period requested)\q
    #
    def series(symbol: nil, 
               report: :legacy, 
               combined: :com,
               config: init,
               after: '1900-01-01',
               lookback: nil,
               set: nil,
               force: false,
               measure: false,
               debug: false
              )
      raise ArgumentError, "Can only build series with given symbol" if symbol.nil?
      symbol_config = Cotcube::Helpers.symbols(symbol: symbol).first
      raise ArgumentError, "Can only build series with known symbol, '#{symbol}' is unknown." if symbol_config.nil?
      puts "Using symbol_config '#{symbol_config}'" if debug

      lookback = config[:default_lookback] if lookback.nil? 
      raise ArgumentError, "Lookback may not be nil, either provide option or set :default_lookback in configfile" if lookback.nil?

      set      = config[:default_set]      if set.nil?
      set      = 'default'                 if set.nil?              

      series_dir  = "#{config[:data_path]}/series/#{symbol}"
      series_file = "#{series_dir}/#{report}_#{combined}_#{set}_#{lookback}.csv"
      puts "Guessing series_file '#{series_file}'" if debug

      `mkdir -p #{series_dir}` unless Dir.exist?(series_dir)

      header_keys = CFTC_HEADERS[report]
        .select   { |key| key.to_s =~ /std_count/ }
        .group_by { |key| key.to_s.split('_')[2] }
        .keys
        .tap      { |k|   k.delete('oi') }

      puts "Using header_keys '#{header_keys}'" if debug


      if set == 'default' or set.nil?
	# load default indicatorset
	indicators = {}
	prefix     = "std_count"
	header_keys.map do |key|
	  indicators["#{prefix}_#{key}_net"] = Cotcube::Indicators.calc(a: "#{prefix}_#{key}_long", b: "#{prefix}_#{key}_short"){|a,b| a - b }
	end
      else
	# load custom indicatorset
	indicators_file = "#{config_path}/indicators-#{set}.rb"
	raise ArgumentError, "Indicatorsfile #{indicators_file} does not exist" unless File.exist? indicators_file
	load indicators_file
	indicators = Cotcube::Indicators.build(lookback: lookback, keys: header_keys)
      end

      if File.exist?(series_file) and (Time.now - File.stat(series_file).mtime).to_i / 86400.0 < 5.0 and not force and not config[:always_force]
	headers_file = "#{config[:headers_path]}/#{report}_#{combined}.json"
	if File.exist? headers_file
	  provide_headers = JSON.parse(File.read(headers_file)).map{|x| x.to_sym}
	else
	  provide_headers = (Cotcube::CftcSource.provide symbol: symbol, report: report, combined: combined, after: (Time.now - 20 * 86000).strftime("%Y-%m-%d")).first.keys
	  File.open(headers_file, 'w'){|f| f << provide_headers.to_json }
	end
	headers         = provide_headers + indicators.keys
	puts 'Returning saved data' if debug
	puts "#{Time.now - measure}: SERIES: returning series from file" if measure

	return CSV.read(series_file, headers: headers, converters: :all).map(&:to_h)
      end

      puts "#{Time.now - measure}: SERIES: before source" if measure

      source = provide(symbol: symbol, report: report, combined: combined, config: config, after: after, measure: measure)

      puts "#{Time.now - measure}: SERIES: after source" if measure

      puts "First source: #{source.first}" if debug
      puts "#{config}" if debug

      source.each do |dataset| 
	indicators.each do |key, lambada|
	  dataset[key] = lambada.call(dataset)
	end
      end
      CSV.open(series_file, 'w') { |csv| source.map{|x| csv << x.values } }

      puts "#{Time.now - measure}: SERIES: returning series from source" if measure
      source

    end
  end
end
