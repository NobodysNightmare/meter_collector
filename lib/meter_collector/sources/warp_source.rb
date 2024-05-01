class MeterCollector
  module Sources
    class WarpSource
      VALUE_ID_TOTAL_ENERGY = 209

      class << self
        def name
          'warp'
        end
      end

      def initialize(config)
        @config = config
      end

      def fetch_readings
        energy = fetch_total_energy
        {
          'total' => Reading.new(energy, 'kWh')
        }
      end

      def to_s
        "Warp Charger at #{base_url}"
      end

      private

      def fetch_total_energy
        ids_response = HTTParty.get("#{base_url}/meters/0/value_ids", digest_auth: { username: username, password: password })
        raise "Unexpected HTTP response code #{ids_response.code}" if ids_response.code != 200

        values_response = HTTParty.get("#{base_url}/meters/0/values", digest_auth: { username: username, password: password })
        raise "Unexpected HTTP response code #{values_response.code}" if values_response.code != 200

        index = ids_response.index(VALUE_ID_TOTAL_ENERGY)

        values_response[index]
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
    end
  end
end
