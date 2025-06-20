require "mqtt"
require "timeout"

class MeterCollector
  module Sources
    class MqttSource

      class << self
        def name
          'mqtt'
        end
      end

      def initialize(config)
        @config = config
      end

      def fetch_readings
        missing_topics = meters.map { |name, c| c.fetch("topic") }
        readings = {}
        MQTT::Client.connect(url) do |c|
          c.subscribe(*missing_topics)
          Timeout.timeout(timeout) do
            while missing_topics.any?
              topic, message = c.get
              c.unsubscribe(topic)
              missing_topics.delete(topic)
              readings[topic] = message
            end
          end
        rescue Timeout::Error
          nil
        end

        meters.transform_values do |meter_config|
          value = readings[meter_config.fetch("topic")]
          next nil if value.nil?

          json_path = meter_config["json_path"]
          value = JSON.parse(value).dig(*json_path.split("/")) if json_path
          Reading.new(Float(value), meter_config.fetch("unit"))
        end.compact
      end

      def to_s
        "MQTT at #{url}"
      end

      private

      def parse_energy(meter)
        watt_minutes = meter.fetch('total')
        watt_hours = watt_minutes / 60
      end

      def url
        @config.fetch('url')
      end

      def timeout
        @config.fetch('timeout')
      end

      def meters
        @config.fetch('meters')
      end
    end
  end
end
