require 'sml/message_body'

require 'sml/types/string'
require 'sml/types/type_length'
require 'sml/types/unsigned_integer'

module Sml
  class Message
    class << self
      def parse(bytes)
        buffer = bytes.dup
        new(buffer)
      end
    end

    def initialize(bytes)
      expect_message_sequence!(bytes)
      @transaction_id = Types::String.parse(bytes)
      @group_no = Types::UnsignedInteger.parse(bytes)
      @abort_on_error = Types::UnsignedInteger.parse(bytes)
      @body = MessageBody.parse(bytes)
      @crc = Types::UnsignedInteger.parse(bytes)
      eom = bytes.shift
      raise ArgumentError, "Expected EndOfSmlMsg, but got #{eom}" if eom > 0
    end

    private

    def expect_message_sequence!(bytes)
      type, length = Types::TypeLength.parse(bytes)
      raise ArgumentError, 'Expected to get a "List of ..."' if type != 7
      raise ArgumentError, "Expected list to have a length of 6, got #{length}" if length != 6
    end
  end
end
