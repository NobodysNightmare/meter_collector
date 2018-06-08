require 'sml/types/type_length'

module Sml
  module Types
    class String
      TYPE = 0x0

      class << self
        def parse(bytes)
          type, length = TypeLength.parse(bytes)
          raise ArgumentError, 'Not a string' unless type == TYPE
          length -= 1 # TL Byte is counted in length
          content = bytes.shift(length)
          return content.map(&:chr).join
        end
      end
    end
  end
end
