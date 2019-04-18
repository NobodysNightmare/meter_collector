require 'sml/types/type_length'

module Sml
  module Types
    class UnsignedInteger
      TYPE = 0x6

      class << self
        def parse(bytes)
          type, length = TypeLength.parse(bytes)
          raise ArgumentError, 'Not an unsigned integer' unless type == TYPE

          length -= 1 # TL Byte is counted in length
          int_bytes = bytes.shift(length)
          result = 0
          int_bytes.each do |b|
            result = (result << 8) | b
          end

          result
        end
      end
    end
  end
end
