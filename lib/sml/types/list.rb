require 'sml/types'

module Sml
  module Types
    class List
      TYPE = 7

      class << self
        def parse(bytes, expected_types: nil)
          type, length = TypeLength.parse(bytes)

          raise ArgumentError, 'Not a list' unless type == TYPE
          if expected_types && expected_types.size != length
            raise ArgumentError, "Expected list to have #{expected_types.size} elements, but got #{length}."
          end

          result = []
          length.times do
            type = expected_types&.shift || Types
            result << type.parse(bytes)
          end
          result
        end
      end
    end
  end
end
