require 'sml/types/list'
require 'sml/types/string'
require 'sml/types/type_length'
require 'sml/types/unsigned_integer'

module Sml
  module Types
    class << self
      PARSERS = {
        0 => Types::String,
        6 => Types::UnsignedInteger,
        7 => Types::List
      }

      def parse(bytes)
        type, _ = TypeLength.peek(bytes)
        type_parser = PARSERS[type]

        raise "Encountered unknown type '#{type}'" unless type_parser

        type_parser.parse(bytes)
      end
    end
  end
end
