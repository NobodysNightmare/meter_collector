class MeterCollector
  module Sources
    class Shelly1Source

      class << self
        def name
          'shelly1'
        end
      end

      def initialize(config)
        @config = config
      end

      def fetch_readings
        status = fetch_status
        meters.map do |name, index|
          meter = status.fetch('meters')[index]
          raise ArgumentError, "Could not find meter with index #{index}" if meter.nil?
          [name, Reading.new(parse_energy(meter), 'Wh')]
        end.to_h
      end

      def to_s
        "Shelly at #{base_url}"
      end

      private

      def fetch_status
        res = HTTParty.get("#{base_url}/status", basic_auth: { username: username, password: password })
        raise "Unexpected HTTP response code #{res.code}" if res.code != 200
        res.to_h
      end

      def parse_energy(meter)
        watt_minutes = meter.fetch('total')
        watt_hours = watt_minutes / 60
      end

      def base_url
        @config.fetch('url')
      end

      def username
        @config.fetch('username')
      end

      def password
        @config.fetch('password')
      end

      def meters
        @config.fetch('meters')
      end
    end
  end
end
