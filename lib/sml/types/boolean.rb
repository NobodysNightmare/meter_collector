require 'sml/types/type_length'

module Sml
  module Types
    class Boolean
      TYPE = 0x4

      class << self
        def parse(bytes)
          type, length = TypeLength.parse(bytes)
          raise ArgumentError, 'Not a boolean' unless type == TYPE
          raise ArgumentError, 'Boolean too long' unless length == 2
          boolean_byte = bytes.shift
          boolean_byte != 0
        end
      end
    end
  end
end
