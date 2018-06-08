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
      while true do
        yield Message.parse(next_message_bytes)
      end
    end

    def next_message_bytes
      attribute = nil
      until attribute == [1, 1, 1, 1] do
        _, attribute = read_to_escape
      end

      message = []
      attribute = []
      until attribute[0] == 0x1a do
        part, attribute = read_to_escape
        message += part
        message += ESCAPE if attribute == ESCAPE
      end

      last_index = -1 - attribute[1]
      # TODO: CRC check
      message[0..last_index]
    end

    private

    def read_to_escape
      bytes = []
      until bytes[-8..-5] == ESCAPE do
        bytes << @io.readbyte
      end

      part = bytes[0..-9]
      escape_attribute = bytes[-4..-1]

      [part, escape_attribute]
    end
  end
end
