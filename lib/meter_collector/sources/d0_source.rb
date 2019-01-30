require 'd0'

require 'meter_collector/reading.rb'

class MeterCollector
  module Sources
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
        SerialPort.open(@port_path) do |port|
          D0::DataPoller.new(port).poll.map do |key, (value, unit)|
            [key, Reading.new(value, unit)]
          end.to_h
        end
      end

      def to_s
        "D0 from #{@port_path}"
      end
    end
  end
end
