# frozen_string_literal: true

module Cotcube
  module CftcSource

    # Goes through CFTCLINKS to iterate over all types of reports
    #
    # @param [Hash] opts
    # @option [Integer, String] Year to be processed, defaults to current year

    def distribute(year: Time.now.year, debug: false, config: init)
      raw_path = "#{config[:data_path]}/raw"
      cot_path = "#{config[:data_path]}/cot"
      CFTC_LINKS.each do |report, a|
	a.each do |combined, _b|
	  puts ("Processing #{report}\t#{combined}\t#{year}") if debug

	  infile  = "#{raw_path}/#{report}_#{combined}_#{year}.csv"
	  outfile = ->(symbol) { "#{cot_path}/#{symbol}/#{report}_#{combined}.csv" }

	  last_report = lambda do |symbol|
	    CSV.read("#{cot_path}/#{symbol}/#{report}_#{combined}.csv").last[1]
	  rescue StandardError
	    '1900-01-01'
	  end

	  cache = {}
	  csv_data = CSV.read(infile).tap { |lines| lines.shift if lines[0][0] =~ /Market/ }
	  csv_data.sort_by { |x| x[2] }.each do |line|
	    next if line[3].length != 6

	    sym = line[3]
	    cache[sym] ||= last_report.call(sym)
	    next if cache[sym] >= line[2]

	    line << "#{report} #{combined}"
	    line.map! { |x| x&.strip }
	    begin
	      CSV.open(outfile.call(sym), 'a+') { |f| f << line }
	    rescue StandardError
	      puts ("Found new id: #{sym}").colorize(:light_green)
	      `mkdir #{cot_path}/#{sym}`
	      CSV.open(outfile.call(sym), 'a+') { |f| f << line }
	    end
	  end
	end
      end
    end

    # print list 

    def available_cftc_ids(config: init, print: true, sort: :exchange)
      command = %Q[find #{init[:data_path]}/cot/* | grep legacy | xargs head -n1  | grep , | awk -v FS=, -v OFS=, '{print $5,$4,$1}' | sed 's/"//g' | sort | uniq]
      result = CSV.parse(`#{command}`.chomp, headers: %i{ exchange id name }).map{|x| x.to_h}
      result = result.uniq{|row| row[:id] }
      if print
        result.sort_by{|x| x[sort]}.each {|row| puts "#{row[:exchange]}\t#{row[:id]}\t#{row[:name]}" }
      end
      result
    end

  end
end
