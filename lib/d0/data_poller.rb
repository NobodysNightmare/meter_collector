require 'serialport'
require 'timeout'

module D0
  class DataPoller
    ACK = 0x06.chr

    IDENTIFICATION_MATCHER = %r{\A/[A-Z][A-Z][A-Za-z]([0-9]).+$}.freeze

    DATA_MATCHER = %r{([^()/!]+\([ ]*[0-9\.]+(?:\*[A-Za-z]+)?\))}.freeze
    DATA_END_MATCHER = /\!/.freeze
    DATA_SPLITTER = %r{([^()/!]+)\([ ]*([0-9\.]+)(?:\*([A-Za-z]+))?\)}.freeze

    DEFAULT_CONFIG = {
      'baud' => 300,
      'data_bits' => 7,
      'stop_bits' => 1,
      'parity' => SerialPort::EVEN
    }.freeze

    BAUD_RATES = {
      '0' => 300,
      '1' => 600,
      '2' => 1200,
      '3' => 2400,
      '4' => 4800,
      '5' => 9600
    }.freeze

    attr_accessor :read_timeout

    def initialize(port)
      @port = port
      @read_timeout = 2
    end

    def poll
      initialize_port
      request_data
      baud_id = read_supported_baudrate
      update_baudrate(baud_id)
      read_data
    end

    def wait_for_pushed_data
      initialize_port(baud: 2400)

      # TODO: handle timeout
      read_data
    end

    private

    def initialize_port(baud: 300)
      @port.set_modem_params(DEFAULT_CONFIG.merge('baud' => baud))
    end

    def request_data
      @port.print "/?!\r\n"
    end

    def read_supported_baudrate
      wait_for IDENTIFICATION_MATCHER
    end

    def update_baudrate(baud_id)
      new_rate = BAUD_RATES[baud_id]
      if new_rate.nil?
        puts "Unsupported baudrate #{baud_id}"
        baud_id = '0'
        new_rate = 300
      end
      @port.print "#{ACK}0#{baud_id}0\r\n"
      sleep(0.5) # wait for message to be sent before baudrate changeover (flushing etc did not help here)
      @port.baud = new_rate
    end

    def read_data
      result = {}
      loop do
        row = wait_for([DATA_MATCHER, DATA_END_MATCHER])
        break if row.nil?

        data = DATA_SPLITTER.match(row)
        result[data[1]] = [Rational(data[2]), data[3]]
      end
      result
    end

    def wait_for(regexes)
      regexes = Array(regexes)
      matches = []
      loop do
        message = nil
        Timeout.timeout(read_timeout) { message = @port.readline }
        matches = regexes.map { |r| r.match(message) }.compact
        break if matches.any?
      end

      matches.first[1]
    end
  end
end
