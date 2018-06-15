require 'httparty'

class EnergyClient
  def initialize(host, api_key)
    @host = host
    @api_key = api_key
  end

  def send_reading(time, serial, value)
    response = HTTParty.post(
      "#{@host}/api/meters/#{serial}/readings",
      headers: {
        'X-API-Key' => @api_key
      },
      body: {
        readings: [
          {
            time: time.iso8601,
            value: value
          }
        ]
      })

      if response.content_type != 'application/json'
        raise "Unexpected Content-Type '#{response.content_type}'"
      end

      return if response.code == 201

      raise response['error']
  end
end
