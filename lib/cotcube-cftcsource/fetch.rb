# frozen_string_literal: true

module Cotcube
  module CftcSource


    # method to download all available historical cot report files
    #
    # @param [Integer, String] year
    # @param [Boolean]         debug
    # @param [Hash]            config
    def fetch(year: Time.now.year, debug: false, silent: false, config: init)

      CFTC_LINKS.each do |report, a|
        a.each do |combined, _b|
          puts ("====> working on #{report}\t#{combined}") if debug
          raw_dir   = "#{config[:data_path]}/raw"

          uri = "#{CFTC_LINKS[report][combined][:hist]}#{year}.zip"
          file_data = nil
          input = HTTParty.get(uri).body
          Zip::InputStream.open(StringIO.new(input)) do |io|
            while entry = io.get_next_entry
              file_data = io.read
            end
          end
          file = "#{raw_dir}/#{report}_#{combined}_#{year}.csv"
          File.write(file, file_data)

          puts "Contents have been written to '#{file}'." if debug
          print "Check whether current date for #{report}_#{combined}_#{year} makes sense: " unless silent
          puts `head -n2 #{file} | tail -n1 | cut -d, -f1,3`.chomp.light_white unless silent
        end
      end
    end
  end
end
