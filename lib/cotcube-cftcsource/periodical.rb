# frozen_string_literal: true

module Cotcube
  module CftcSource

    def weekly_run
      configfile = '/etc/cotcube/cftcsource.yml'
      begin
        `sed -i '$ d' #{configfile} && echo 'always_force: true' >> #{configfile}`
        fetch && distribute && exports && exports(lookback: 26) && reorganize
      ensure
        `sed -i '$ d' #{configfile} && echo 'always_force: false' >> #{configfile}`
      end
    end
  end
end
