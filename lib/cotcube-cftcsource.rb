# frozen_string_literal: true

# require 'bundler/setup'
# require 'rubygems/package'
require 'active_support'
require '../ci-dev/lib/cotcube-indicators'
require 'cotcube-helpers'
require 'colorize'
require 'date' unless defined?(DateTime)
require 'csv'  unless defined?(CSV)
require 'yaml' unless defined?(YAML)
require 'httparty'
require 'zip'


require_relative 'cotcube-cftcsource/init'
require_relative 'cotcube-cftcsource/constants'
require_relative 'cotcube-cftcsource/dates'
require_relative 'cotcube-cftcsource/fetch'
require_relative 'cotcube-cftcsource/distribute'
require_relative 'cotcube-cftcsource/provide'
require_relative 'cotcube-cftcsource/series'

# TODO: make these private files another gem, that finally requires _this_ gem to run
private_files = Dir[__dir__ + '/cotcube-cftcsource/private/*.rb']
private_files.each do |file| 
#  # puts 'Loading private module extension ' + file.chomp
  require file.chomp
end

module Cotcube
  module CftcSource
    include Cotcube::Helpers
    module_function :config_path, # provides the path of configuration directory
      :config_prefix,             # provides the prefix of the configuration directory according to OS-specific FSH
      :init,                      # checks whether environment is prepared and returns the config hash
      :date_of_last_report,       # returns the date of the currently last locally available report
      :current_cot_date_on_website, # returns the date of the current report officially available on cftc.gov
      :fetch,                     # downloads all (annual) reports, based on given year
      :distribute,                # distributes currently downloaded ('fetch'ed) reports to id_based directories
      :available_cftc_ids,        # returns a list of locally available cftc ids 
      :provide,                   # returns a series based on id (or symbol) and report / combined
      :series                     # returns a series based on provide, after application of indicator set

    # please not that module_functions of source provided in private files must be published there
  end
end
