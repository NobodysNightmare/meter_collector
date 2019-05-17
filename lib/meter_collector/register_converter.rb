class MeterCollector
  # Converts values found in Modbus registers to usable
  # representations of numbers.
  # Supports integers (any number of registers) and floating
  # point numbers (2 registers -> 32 Bit)
  class RegisterConverter
    # When reading floats stored in registers, we will return them
    # as decimals to Ruby.
    # Choosing a precision that can represent up to ten billion
    # watt hours (9,999,999.999 kWh)
    FLOAT_PRECISION = 10

    def initialize(format)
      @format = format.to_sym
    end

    def convert_registers(registers)
      value = combine_holding_registers(registers)
      convert(value, @format)
    end

    private

    def combine_holding_registers(registers)
      result = 0
      registers.each do |v|
        result = result << 16
        result += v
      end

      result
    end

    def convert(value, format)
      case format
      when :integer
        value
      when :float
        int_bytes_to_float(value)
      else
        raise "Unknown number format #{format}"
      end
    end

    def int_bytes_to_float(value)
      bytes = []
      while value > 0
        bytes.unshift(value & 0xFF)
        value >>= 8
      end

      bytes = bytes.map(&:chr).join
      raise "Unsupported float size (#{bytes.size * 8} Bit)" unless bytes.size == 4

      BigDecimal(bytes.unpack('g').first, FLOAT_PRECISION)
    end
  end
end
