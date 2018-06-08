require 'sml/types/type_length'

module Sml
  module Types
    class SignedInteger
      TYPE = 0x5

      class << self
        def parse(bytes)
          type, length = TypeLength.parse(bytes)
          raise ArgumentError, 'Not a signed integer' unless type == TYPE
          length -= 1 # TL Byte is counted in length
          int_bytes = bytes.shift(length)
          result = 0
          int_bytes.each do |b|
            result = (result << 8) | b
          end

          raise 'Remember to take care of the sign!'
          result
        end
      end
    end
  end
end
