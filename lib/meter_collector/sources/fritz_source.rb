class MeterCollector
  module Sources
    class FritzSource
      EMPTY_SID = '0000000000000000'

      class << self
        def name
          'fritz'
        end
      end

      def initialize(config)
        @config = config
      end

      def fetch_readings
        with_session do |sid|
          switches.map do |name, ain|
            [name, Reading.new(fetch_energy(sid, ain), 'Wh')]
          end.to_h
        end
      end

      def to_s
        "FritzBox at #{base_url}"
      end

      private

      def with_session
        res = HTTParty.get("#{base_url}/login_sid.lua")
        session_info = res.fetch('SessionInfo')

        if(session_info.fetch('BlockTime').to_i.positive?)
          raise 'Login is blocked. Rate limit reached.'
        end

        challenge = session_info.fetch('Challenge')
        response = "#{challenge}-#{Digest::MD5.hexdigest("#{challenge}-#{password}".encode(Encoding::UTF_16LE))}"

        res = HTTParty.get("#{base_url}/login_sid.lua", query: { username: username, response: response })

        sid = res.dig('SessionInfo', 'SID')
        raise 'Could not authenticate' if sid == EMPTY_SID
        result = yield sid

        HTTParty.get("#{base_url}/login_sid.lua", query: { logout: 1, sid: sid })
        result
      end

      def fetch_energy(sid, ain)
        energy = fetch(sid: sid, switchcmd: 'getswitchenergy', ain: ain)
        Integer(energy)
      end

      def fetch_name(sid, ain)
        fetch(sid: sid, switchcmd: 'getswitchname', ain: ain)
      end

      def fetch_switches
        with_session do |sid|
          res = fetch(sid: sid, switchcmd: 'getswitchlist')
          res.split(',').map do |ain|
            [fetch_name(sid, ain), ain]
          end.to_h
        end
      end

      def fetch(**options)
        res = HTTParty.get("#{base_url}/webservices/homeautoswitch.lua", query: options)
        res.to_s.strip
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

      def switches
        @config.fetch('switches', fetch_switches)
      end
    end
  end
end
