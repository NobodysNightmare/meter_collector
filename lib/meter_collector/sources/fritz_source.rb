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

      def list_switches
        with_session do |sid|
          res = HTTParty.get("#{base_url}/webservices/homeautoswitch.lua", query: { sid: sid, switchcmd: 'getswitchlist' })
          res.to_s.split(',').each do |ain|
            puts "#{ain}: #{fetch_name(sid, ain)}"
          end
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
          puts 'Aborting, client is blocked.'
          return nil
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
        res = HTTParty.get("#{base_url}/webservices/homeautoswitch.lua", query: { sid: sid, switchcmd: 'getswitchenergy', ain: ain })
        Integer(res.to_s)
      end

      def fetch_name(sid, ain)
        res = HTTParty.get("#{base_url}/webservices/homeautoswitch.lua", query: { sid: sid, switchcmd: 'getswitchname', ain: ain })
        res.to_s
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
        @config.fetch('switches')
      end
    end
  end
end
