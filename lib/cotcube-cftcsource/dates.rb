# frozen_string_literal: true

module Cotcube
  module CftcSource

    # method to parse current years raw CFTC cot_files and return the latest available date
    #
    # @return [DateTime] DateTime object containing the date found
    def date_of_last_report(config: init_config)
      files = Dir["#{config[:data_path]}/raw/*#{Time.now.strftime('%Y')}.csv"]
      DateTime.strptime(CSV.read(files[0]).tap { |x| x.shift if x[0][0] =~ /Market/ }.map { |x| x[2] }.max, '%Y-%m-%d') rescue nil
    end

    # method to extract the currently available most recent COT report from the according CFTC website
    #
    # @return [DateTime] a DateTime object containing the extracted date
    def current_cot_date_on_website
      uri = 'https://www.cftc.gov/MarketReports/CommitmentsofTraders/index.htm'
      raw = HTTParty.get(uri).to_s
      encoding_options = {
        :invalid           => :replace,  # Replace invalid byte sequences
        :undef             => :replace,  # Replace anything not defined in ASCII
        :replace           => '',        # Use a blank for those replacements
        :universal_newline => true       # Always break lines with \n
      }
      line = raw.each_line.select{|x| x if x =~ /Reports Dated/ }[0].encode(Encoding.find('ASCII'), encoding_options)
      date_string = line.split('Dated ').last.split('- Current').first
      DateTime.strptime(date_string, '%B %d,%Y')
    end
  end
end
