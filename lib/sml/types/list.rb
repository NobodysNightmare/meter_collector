require 'sml/types'

module Sml
  module Types
    class List
      TYPE = 7

      class << self
        def parse(bytes)
          type, length = TypeLength.parse(bytes)

          raise ArgumentError, 'Not a list' unless type == TYPE

          result = []
          length.times do |i|
            result << Types.parse(bytes)
          end
          result
        end
      end
    end
  end
end
