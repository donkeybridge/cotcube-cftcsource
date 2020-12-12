#!/usr/bin/env ruby

require_relative '../lib/cotcube-cftcsource.rb'

s = Cotcube::CftcSource.signals symbol:  ARGV[0], report: ARGV[1].downcase.to_sym, human: false, count: 800, quiet: true
s.each {|x| puts x} 

