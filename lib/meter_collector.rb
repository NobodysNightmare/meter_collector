require 'meter_collector/energy_client'
require 'meter_collector/sources'

class MeterCollector
  def initialize(configuration)
    @config = configuration
  end

  def print_values
    each_source_with_config do |source, config|
      puts " ### #{source}"
      readings = source.fetch_readings
      readings.each do |key, reading|
        print "#{key}: #{reading.value.to_f} #{reading.unit}"
        if unit == 'kWh'
          print " (#{to_wh(reading.value, reading.unit).to_i} Wh)"
        end
        puts
      end
      puts
    end
  end

  def upload_values
    each_source_with_config do |source, config|
      time = Time.now
      readings = source.fetch_readings
      config['uploads'].each do |key, upload_config|
        reading = readings[key]
        unless reading
          puts "Skipping '#{key}': not in result set."
          next
        end
        value = to_wh(reading.value, reading.unit).to_i
        client = EnergyClient.new(upload_config['host'], upload_config['api_key'])
        client.send_reading(time, upload_config['serial'], value)
      end
    end
  end

  private

  def each_source_with_config
    @config['sources'].each do |config|
      yield Sources.create_with_config(config), config
    end
  end

  def to_wh(value, unit)
    case unit
    when 'Wh'
      value
    when 'kWh'
      value * 1000
    else
      raise "Unsupported unit '#{unit}'"
    end
  end
end
