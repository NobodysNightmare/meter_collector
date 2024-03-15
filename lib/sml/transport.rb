require 'sml/message'

module Sml
  # Reads SML Messages from an IO that
  # implements the SML Transport Protocol Version 1
  class Transport
    ESCAPE = [0x1b, 0x1b, 0x1b, 0x1b].freeze

    def initialize(io)
      @io = io
    end

    def each_message
      loop do
        tree = Sml::Types.parse(next_message_bytes)
        yield Message.new(tree)
      end
    end

    def next_message_bytes
      attribute = nil
      _, attribute = read_to_escape until attribute == [1, 1, 1, 1]

      message = []
      attribute = []
      until attribute[0] == 0x1a
        part, attribute = read_to_escape
        message += part
        message += ESCAPE if attribute == ESCAPE
      end

      last_index = -1 - attribute[1]
      message[0..last_index]
    end

    private

    def read_to_escape
      bytes = []
      bytes << @io.readbyte until bytes[-8..-5] == ESCAPE

      part = bytes[0..-9]
      escape_attribute = bytes[-4..-1]

      [part, escape_attribute]
    end
  end
end
