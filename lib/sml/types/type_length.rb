module Sml
  module Types
    class TypeLength
      TYPE_MASK        = 112 # 0111 0000
      TYPE_OFFSET      = 4
      LENGTH_MASK      = 15  # 0000 1111
      MORE_LENGTH_MASK = 128 # 1000 0000
      class << self
        def peek(bytes)
          #TODO: improve this
          # Assumption: There is no TL field longer than 10 Byte
          buffer = bytes[0..10]
          parse(buffer)
        end

        def parse(bytes)
          tl = bytes.shift
          type = (tl & TYPE_MASK) >> TYPE_OFFSET
          length = fetch_length(tl, bytes)
          [type, length]
        end

        private

        def fetch_length(tl, bytes)
          length_bytes = [tl & LENGTH_MASK]
          while (tl & MORE_LENGTH_MASK) > 0 do
            tl = bytes.shift
            raise ArgumentError 'Unexpected Bits in TL Length extension' if (tl & TYPE_MASK) > 0
            length_bytes << tl & LENGTH_MASK
          end

          length = 0
          length_bytes.each do |b|
            length = (length << 4) | b
          end
          length
        end
      end
    end
  end
end
