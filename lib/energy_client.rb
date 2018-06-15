require 'httparty'

class EnergyClient
  def initialize(host, api_key)
    @host = host
    @api_key = api_key
  end

  def send_reading(time, serial, value)
    HTTParty.post(
      "#{host}/api/meters/#{serial}/readings",
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

      # TODO: validate response
  end
end
