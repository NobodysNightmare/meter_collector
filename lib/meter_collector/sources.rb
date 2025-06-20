require 'meter_collector/sources/d0_source.rb'
require 'meter_collector/sources/d0_passive_source.rb'
require 'meter_collector/sources/fritz_source.rb'
require 'meter_collector/sources/modbus_source.rb'
require 'meter_collector/sources/mqtt_source.rb'
require 'meter_collector/sources/shelly1_source.rb'
require 'meter_collector/sources/vzlogger_source.rb'
require 'meter_collector/sources/warp_source.rb'

class MeterCollector
  module Sources
    AVAILABLE_SOURCES = [
      Sources::D0Source,
      Sources::D0PassiveSource,
      Sources::FritzSource,
      Sources::ModbusSource,
      Sources::MqttSource,
      Sources::Shelly1Source,
      Sources::VzloggerSource,
      Sources::WarpSource
    ].freeze

    class << self
      def create_with_config(config)
        source = AVAILABLE_SOURCES.find { |s| s.name == config.fetch('type') }
        raise ArgumentError, "Can't find source for '#{config.fetch('type')}'" unless source

        source.new(config)
      end
    end
  end
end
