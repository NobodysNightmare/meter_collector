require 'meter_collector/reading.rb'
require 'rmodbus'

class MeterCollector
  module Sources
    # Reads from a modbus device, either connected via serial port (Modbus RTU)
    # or via network (ModBus TCP).
    # Will only return readings for configured registers (or register spans).
    class ModbusSource
      REGISTER_TYPES = %i[holding input].freeze

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
            value = read_register(slave,
                                  register_config.fetch('type', :holding).to_sym,
                                  register_config.fetch('address'),
                                  register_config.fetch('register_count'))
            converter = RegisterConverter.new(register_config.fetch('format', 'integer'))
            value = converter.convert_registers(value)

            [register_name, Reading.new(value, register_config.fetch('unit'))]
          end.to_h
        end
      end

      def to_s
        "Modbus from #{slave_url || slave_device_path}"
      end

      private

      def with_modbus_slave
        result = nil
        with_modbus_client do |client|
          client.with_slave(@config.fetch('unit_id')) do |slave|
            result = yield slave
          end
        end
        result
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

        return @slave_url = nil unless @config.key?('url')

        url = URI.parse(@config.fetch('url'))
        unless url.scheme == 'modbus'
          raise ArgumentError,
                "Invalid scheme for modbus URL. Expected 'modbus'"
        end

        url.port = 502 if url.port.nil?

        @slave_url = url
      end

      def read_register(slave, register_type, address, register_count)
        raise "Unexpected register type #{register_type}." unless REGISTER_TYPES.include?(register_type)

        slave.public_send(
          "read_#{register_type}_registers",
          address,
          register_count
        )
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
    end
  end
end
