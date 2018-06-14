require 'serialport'
require 'timeout'

module D0
  class DataPoller
    ACK = 0x06.chr

    IDENTIFICATION_MATCHER = %r{\A(/[A-Z][A-Z][A-Za-z][0-9].+)\z}
    DATA_MATCHER = %r{([0-9\.]+\([0-9\.]+\*[A-Za-z]+\))}
    DATA_END_MATCHER = %r{\!}
    DATA_SPLITTER = %r{([0-9\.]+)\(([0-9\.]+)\*([A-Za-z])\)}

    DEFAULT_CONFIG = {
      'baud' => 300,
      'data_bits' => 7,
      'stop_bits' => 1,
      'parity' => SerialPort::EVEN
    }

    BAUD_RATES = {
      '0' => 300,
      '1' => 600,
      '2' => 1200,
      '3' => 2400,
      '4' => 4800,
      '5' => 9600
    }

    attr_accessor :read_timeout

    def initialize(port)
      @port = port
      @read_timeout = 2
    end

    def poll
      initialize_port
      request_data
      read_identification
      acknowledge_identification(0)
      read_data
    end

    private

    def initialize_port
      @port.set_modem_params(DEFAULT_CONFIG)
    end

    def request_data
      @port.print "/?!\r\n"
    end

    def read_identification
      ident = wait_for IDENTIFICATION_MATCHER
      puts "Identification: #{ident}"
      ident
    end

    def acknowledge_identification(baud_id)
      @port.print "#{ACK}0#{baud_id}0\r\n"
    end

    def read_data
      result = {}
      while true do
        data = wait_for([DATA_MATCHER, DATA_END_MATCHER])
        break if data.nil?
        data = DATA_SPLITTER.match(data)
        result[data[1]] = [data[2], data[3]]
      end
      result
    end

    def wait_for(regexes)
      regexes = Array(regexes)
      while true do
        Timeout.timeout(read_timeout) { message = @port.readline }
        matches = regexes.map { |r| r.match(message) }.compact
        break if matches.any?
      end

      matches.first[1]
    end
  end
end
