# frozen_string_literal: true

module Cotcube
  module CftcSource

    def weekly_run
      configfile = '/etc/cotcube/cftcsource.yml'
      begin
        `sed -i '$ d' #{configfile} && echo 'always_force: true' >> #{configfile}`
        fetch && distribute && exports && exports(lookback: 26)
        iterate_signals symbol: 'DX', selected: false, count: 20
      ensure
        `sed -i '$ d' #{configfile} && echo 'always_force: false' >> #{configfile}`
      end
    end
  end
end
