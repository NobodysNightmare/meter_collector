$LOAD_PATH << './lib'

require 'd0'
require 'sml'

def bits_of(integer)
  puts 'MSB  LSB'
  mask = 128
  8.times do
    print (mask & integer).zero? ? '0' : '1'
    mask = mask >> 1
  end
  puts
end

require 'irb'

IRB.start
