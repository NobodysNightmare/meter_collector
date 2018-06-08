require 'sml/types'

module Sml
  class MessageBody
    class << self
      def parse(bytes)
        choice = Types::List.parse(bytes)
        raise ArgumentError, "Expected CHOICE to have a length of 2, got #{choice.size}" if choice.size != 2

        raise 'No clue how to parse a message body ;-)'
      end
    end
  end
end
