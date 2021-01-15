#!/usr/bin/env ruby

require_relative '../lib/cotcube-cftcsource.rb'

if ARGV[0].nil?
  raise ArgumentError, "Need symbol to continue"
end
symbol = ARGV[0].upcase
report = ARGV[1].nil? ? :legacy : ARGV[1].downcase
filter = ARGV[2].nil? ? nil : /_#{ARGV[2].downcase}_/

s = Cotcube::CftcSource.signals symbol:  ARGV[0], report: report.to_sym, human: false, count: 800, quiet: true, filter: filter
s.each {|x| puts x} 
