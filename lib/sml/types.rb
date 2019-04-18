require 'sml/types/boolean'
require 'sml/types/end_of_sml_message'
require 'sml/types/list'
require 'sml/types/signed_integer'
require 'sml/types/string'
require 'sml/types/type_length'
require 'sml/types/unsigned_integer'

module Sml
  module Types
    class << self
      PARSERS = {
        0 => Types::String,
        4 => Types::Boolean,
        5 => Types::SignedInteger,
        6 => Types::UnsignedInteger,
        7 => Types::List
      }.freeze

      def parse(bytes)
        type, length = TypeLength.peek(bytes)

        if length.zero? && type.zero?
          # EndOfSmlMsg is a special case
          return Types::EndOfSmlMessage.parse(bytes)
        end

        type_parser = PARSERS[type]

        raise "Encountered unknown type '#{type}'" unless type_parser

        type_parser.parse(bytes)
      end
    end
  end
end
