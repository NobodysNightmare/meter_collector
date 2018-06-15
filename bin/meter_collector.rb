root = File.expand_path('..', File.absolute_path(__dir__))
$LOAD_PATH << "#{root}/lib"

require 'd0'
require 'meter_collector'
require 'meter_collector/cli/options'
require 'yaml'


options = MeterCollector::Cli::Options.new
options.parse!(ARGV)
options.validate!

configuration = YAML.load_file(options.config_file)
collector = MeterCollector.new(configuration)

case options.mode
when :print
  collector.print_values
when :upload
  collector.upload_values
else
  raise "Unexpected mode '#{options[:mode]}'"
end
