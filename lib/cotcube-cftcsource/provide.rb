# frozen_string_literal: true

module Cotcube
  module CftcSource
    def provide(symbol: nil,         # The barchart symbol of the contract
                id: nil,             # The CFTC ID of the contract
                report: :legacy,       # report type (legacy, disagg, financial, cit)
                combined: :com,      # combined of fut_only
                after: '1900-01-01', # start at given date
                subset: true,        # set to false to return full data
                measure: false, 
                config: init,        # 
                debug: false)        #

      after = DateTime.strptime(after, '%Y-%m-%d') if after.is_a? String

      unless symbol.nil? 
        symbol_config = Cotcube::Helpers.symbols(symbol: symbol).first
        symbol_id     = symbol_config[:id]
        raise ArgumentError, "Could not find match in #{config[:symbols_file]} for given symbol #{symbol}" if symbol_id.nil? 
        raise ArgumentError, "Mismatching symbol #{symbol} and given id #{id}" if not id.nil? and symbol_id != id
        id = symbol_id
      end
      raise ArgumentError, "Need either :symbol or :id as parameter" if id.nil? 

      id_path    = "#{config[:data_path]}/cot/#{id}"
      data_file  = "#{id_path}/#{report}_#{combined}.csv"

      raise RuntimeError, "No data found for requested :id (#{id_path} does not exist)" unless Dir.exist?(id_path)
      raise RuntimeError, "No data found for requested :report (#{report} #{combined} in #{id_path}" unless File.exist?(data_file)

      puts "#{Time.now - measure}: PROVIDE: before CSV parse" if measure
      raw        = `cat #{data_file} | sed -e 's/\r//'`
      data       = CSV.parse(raw, row_sep: :auto, converters: :all, headers: CFTC_HEADERS[report]).map do |row|
        d = row.to_h
        d[:date] = d[:date2].strftime('%Y-%m-%d')
        d
      end
      puts "#{Time.now - measure}: PROVIDE: after CSV parse" if measure
      data.select! { |x| x[:date2] > after } if after
      data.sort!   { |x| x[:date2] }.uniq!{ |x| x[:date2] }
      data.reverse!

      if subset 
        data.map do |dataset|
          dataset.map do |key,value|
            dataset.delete(key) if       key.to_s =~ (/_traders_/)  || 
              key.to_s =~ (/_pct_/)   || key.to_s =~ (/_conc_/)     || 
              key.to_s =~ (/^other_/) || key.to_s =~ (/^old_/)      || key.to_s =~ (/_change_/) ||
              [ :units, :"CFTCContractMarketCode(Quotes)", :"CFTCMarketCodeinInitials(Quotes)",
                :"CFTCCommodityCode(Quotes)", :name,  :cftcid3, :date2 ].include?(key)
          end
        end
      end
      puts "#{Time.now - measure}: PROVIDE: after subset application, returning " if measure

      data
    end

  end
end
