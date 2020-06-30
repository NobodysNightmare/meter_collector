require 'httparty'

class MeterCollector
  class EnergyClient
    def initialize(host, api_key)
      @host = host
      @api_key = api_key
    end

    def send_reading(time, serial, value)
      response = HTTParty.post(
        "#{@host}/api/meters/#{serial}/readings",
        headers: { 'Authorization' => "Bearer #{@api_key}" },
        body: format_body(time, value)
      )

      validate_response(response)
    end

    private

    def format_body(time, value)
      {
        readings: [
          {
            time: time.iso8601,
            value: value
          }
        ]
      }
    end

    def validate_response(response)
      if response.content_type != 'application/json'
        message = "Unexpected Content-Type '#{response.content_type}'"
        message = "#{message} #{response.to_s}"
        raise message
      end

      return if response.code == 201

      raise response['error']
    end
  end
end
