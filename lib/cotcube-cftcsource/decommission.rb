# frozen_string_literal: true

module Cotcube
  module CftcSource
    # move expired
    
  def move_expired_reports
    Dir['/var/cotcube/cftc/cot/*'].each do |dir|
      target = "/var/cotcube/cftc/expired/#{dir.split('/').last}/"
      Dir["#{dir}/*.csv"].each do |file|
        next unless CSV.read(file, converters: :all).last[2] < Date.today - 30

        xdebug "Moving #{file} to #{target}"
        `mkdir -p #{target}` unless File.exist? target
        `mv #{file} #{target}`
      end
      if Dir["#{dir}/*"].empty?
        xdebug "Removing #{dir}"
        `rm -rf #{dir}`
      end
    end
  end

  end
end
