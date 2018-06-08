require 'sml/types/type_length'

module Sml
  module Types
    class EndOfSmlMessage
      class << self
        def parse(bytes)
          type, length = TypeLength.parse(bytes)
          raise ArgumentError, 'Not end of an sml message' unless type.zero? && length.zero?
          nil
        end
      end
    end
  end
end
