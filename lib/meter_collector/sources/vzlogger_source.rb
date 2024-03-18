require 'd0'

require 'meter_collector/reading.rb'

class MeterCollector
  module Sources
    # Reads from a vzlogger with enabled HTTP interface
    class VzloggerSource
      class << self
        def name
          'vzlogger'
        end
      end

      def initialize(config)
        @config = config
      end

      def fetch_readings
        response = HTTParty.get(url)

        channels.to_h do |chan|
          name = chan.fetch('name')
          response_channel = response.fetch('data').find { |c| c['uuid'] == chan.fetch('uuid') }
          age = Time.now.to_i - response_channel.fetch('last') / 1000
          next [name, nil] if age > 60

          value = response_channel.dig('tuples', 0, 1)
          [name, Reading.new(value, chan.fetch('unit'))]
        end.compact
      end

      def to_s
        "VZLogger from #{url}"
      end

      private

      def url
        @config.fetch('url')
      end

      def channels
        @config.fetch('channels')
      end
    end
  end
end
