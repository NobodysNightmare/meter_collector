require 'd0'

require 'meter_collector/reading.rb'

class MeterCollector
  module Sources
    # Reads from a D0 (IEC 62056-21 compliant) meter connected via
    # (infrared) serial port.
    # Will return all readings sent by the meter.
    class D0Source
      class << self
        def name
          'd0'
        end
      end

      def initialize(config)
        @port_path = config['path']
      end

      def fetch_readings
        result = nil
        SerialPort.open(@port_path) do |port|
          result = D0::DataPoller.new(port).poll.map do |key, (value, unit)|
            [key, Reading.new(value, unit)]
          end.to_h
        end
        result
      end

      def to_s
        "D0 from #{@port_path}"
      end
    end
  end
end
