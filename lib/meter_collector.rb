require 'meter_collector/energy_client'

class MeterCollector
  def initialize(configuration)
    @config = configuration
  end

  def print_values
    each_port_with_config do |port, config|
      puts " ### Port #{config['path']}"
      result = D0::DataPoller.new(port).poll
      result.each do |key, (value, unit)|
        print "#{key}: #{value.to_f} #{unit}"
        if unit == 'kWh'
          print " (#{to_wh(value, unit).to_i} Wh)"
        end
        puts
      end
      puts
    end
  end

  def upload_values
    each_port_with_config do |port, config|
      time = Time.now
      result = D0::DataPoller.new(port).poll
      config['uploads'].each do |key, upload_config|
        value, unit = result[key]
        unless value
          puts "Skipping '#{key}': not in result set."
        end
        value = to_wh(value, unit).to_i
        client = EnergyClient.new(upload_config['host'], upload_config['api_key'])
        client.send_reading(time, upload_config['serial'], value)
      end
    end
  end

  private

  def each_port_with_config
    @config['ports'].each do |config|
      SerialPort.open(config['path']) do |port|
        yield port, config
      end
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
