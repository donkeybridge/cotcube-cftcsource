# frozen_string_literal: true

require_relative '../lib/cotcube-cftcsource'

tmp_root = `mktemp -d`.chomp
puts `echo 'rm -rf #{tmp_root}' | at #{(Time.now + 180).strftime('%H:%M') }`
puts "Using #{tmp_root} as data directory"
config_file_name = 'cftcsource.testing.yml'
config_file = "/etc/cotcube/#{config_file_name}"
config_file_content = <<-YML
---
data_path: '#{tmp_root}'
...
YML

File.write(config_file, config_file_content)

RSpec.describe Cotcube::CftcSource do
  local_init = lambda { Cotcube::CftcSource.init(config_file_name: config_file_name) } 
  it 'should not raise running .symbols' do 
    expect{Cotcube::CftcSource.symbols}.not_to raise_error
  end
  it 'should not raise running .init and prepare directories' do 
    expect{Cotcube::CftcSource.init(config_file_name: config_file_name)}.not_to raise_error
    ['cot', 'raw', 'series'].each do |dir| 
      expect(Pathname.new("#{tmp_root}/#{dir}")).to be_directory
    end
  end
  it 'should fetch without raising' do 
    expect{Cotcube::CftcSource.fetch(year: Time.now.strftime('%Y'), silent: true, config: local_init.call)}.not_to raise_error
  end
  it 'should distribute without raising' do 
    expect{Cotcube::CftcSource.distribute(year: Time.now.strftime('%Y'), config: local_init.call)}.not_to raise_error
  end
  it 'should display date of late report' do
    expect{Cotcube::CftcSource.date_of_last_report(config: local_init.call)}.not_to raise_error
  end
  it 'should display current cot date on website' do
    expect{Cotcube::CftcSource.current_cot_date_on_website}.not_to raise_error
  end
  # ET 13874U
  # NM 209747
  it 'should fail with improper id or symol' do
    expect{Cotcube::CftcSource.provide(config: local_init.call)}.to raise_error(ArgumentError)
    expect{Cotcube::CftcSource.provide(id: '000000', config: local_init.call)}.to raise_error(RuntimeError)
    expect{Cotcube::CftcSource.provide(id: '000000', symbol: "ES", config: local_init.call)}.to raise_error(ArgumentError)
    expect{Cotcube::CftcSource.provide(id: '13874A', symbol: "NQ", config: local_init.call)}.to raise_error(ArgumentError)
  end
  it 'should load with proper id or symbol' do
    expect{Cotcube::CftcSource.provide(id: '13874A', config: local_init.call)}.not_to raise_error
    expect{Cotcube::CftcSource.provide(symbol: 'ES', config: local_init.call)}.not_to raise_error
  end
end

