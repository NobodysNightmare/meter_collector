require 'meter_collector/reading.rb'

class MeterCollector
  module Sources
    # Reads from a modbus device, either connected via serial port (Modbus RTU)
    # or via network (ModBus TCP).
    # Will only return readings for configured registers (or register spans).
    class ModbusSource
      class << self
        def name
          'modbus'
        end
      end

      def initialize(config)
        @config = config
      end

      def fetch_readings
        with_modbus_slave do |slave|
          registers.map do |register_name, register_config|
            value = slave.read_holding_registers(
                      register_config.fetch('address'),
                      register_config.fetch('register_count')
                    )
            value = combine_holding_registers(value)
            [
              register_name,
              Reading.new(value, register_config.fetch('unit'))
            ]
          end.to_h
        end
      end

      def to_s
        "Modbus from #{slave_url || slave_device_path}"
      end

      private

      def with_modbus_slave(&block)
        with_modbus_client do |client|
          client.with_slave(@config.fetch('unit_id'), &block)
        end
      end

      def with_modbus_client(&block)
        if slave_url
          ModBus::TCPClient.new(slave_url.host, slave_url.port, &block)
        elsif slave_device_path
          ModBus::RTUClient.connect(slave_device_path, slave_baud_rate, &block)
        else
          raise ArgumentError,
                "Can't find configuration for modbus client. " \
                'Please specify how to connect (url or path + baud)'
        end
      end

      def slave_url
        return @slave_url if defined? @slave_url
        unless @config.key?('url')
          @slave_url = nil
          return nil
        end

        url = URI.parse(@config.fetch('url'))
        unless url.scheme == 'modbus'
          raise ArgumentError,
                "Invalid scheme for modbus URL. Expected 'modbus'"
        end

        url.port = 502 if url.port.nil?

        @slave_url = url
      end

      def slave_device_path
        @config.fetch('path', nil)
      end

      def slave_baud_rate
        @config.fetch('baud', 9600)
      end

      def registers
        @config.fetch('registers')
      end

      def combine_holding_registers(values)
        result = 0
        values.each do |v|
          result = result << 16
          result += v
        end

        result
      end
    end
  end
end
