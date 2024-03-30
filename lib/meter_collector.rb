require 'meter_collector/energy_client'
require 'meter_collector/register_converter'
require 'meter_collector/sources'

require 'mqtt'

class MeterCollector
  def initialize(configuration)
    @config = configuration
  end

  def print_values
    each_source_with_config do |source, _config|
      puts " ### #{source}"
      readings = source.fetch_readings
      readings.each do |key, reading|
        print "#{key}: #{reading.value.to_f} #{reading.unit}"
        value, unit = to_base_unit(reading.value, reading.unit)
        print " (#{value.to_i} Wh)" if reading.unit != unit
        puts
      end
      puts
    end
  end

  def upload_values
    each_source_with_config do |source, config|
      time = Time.now
      readings = source.fetch_readings
      (config['uploads'] || []).each do |key, upload_config|
        reading = readings[key]
        unless reading
          puts "Skipping '#{key}': not in result set."
          next
        end

        upload_reading(reading, time, upload_config)
      end

      (config['mqtt_publishes'] || []).each do |key, upload_config|
        reading = readings[key]
        unless reading
          puts "Skipping '#{key}': not in result set."
          next
        end

        publish_reading(reading, time, upload_config)
      end
    end
  end

  private

  def each_source_with_config
    @config['sources'].each do |config|
      yield Sources.create_with_config(config), config
    end
  end

  def upload_reading(reading, time, upload_config)
    value, _ = to_base_unit(reading.value, reading.unit)
    client = EnergyClient.new(upload_config['host'], upload_config['api_key'])
    client.send_reading(time, upload_config['serial'], value.to_i)
  end

  def publish_reading(reading, time, upload_config)
    MQTT::Client.connect(upload_config['url']) do |client|
      value, unit = to_base_unit(reading.value, reading.unit)
      payload = {
        time: time.iso8601,
        value: value.to_i,
        unit: unit
      }
      client.publish(upload_config['topic'], payload.to_json)
    end
  end

  def to_base_unit(value, unit)
    case unit
    when 'Wh'
      [value, 'Wh']
    when 'W'
      [value, 'W']
    when 'kWh'
      [value * 1000, 'Wh']
    when 'kW'
      [value * 1000, 'W']
    else
      raise "Unsupported unit '#{unit}'"
    end
  end
end
