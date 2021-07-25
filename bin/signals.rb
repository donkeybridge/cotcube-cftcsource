#!/usr/bin/env ruby

require_relative '../lib/cotcube-cftcsource.rb'

if ARGV[0].nil?
  raise ArgumentError, "Need symbol to continue"
end
symbol = ARGV[0].upcase
lookback = ARGV[1].nil? ? 55 : ARGV[1].to_i
report = ARGV[2].nil? ? :legacy : ARGV[2].downcase
filter = ARGV[3].nil? ? nil : /_#{ARGV[3].downcase}_/

s = Cotcube::CftcSource.signals symbol: symbol, lookback: lookback, report: report.to_sym, human: false, count: 800, quiet: true, filter: filter
s.each {|x| puts x} 
