$LOAD_PATH << './lib'

require 'sml'

file = File.open('examples/sml-transport')
Sml::Transport.new(file).each_message do |message|
  puts "Message: #{message}"
end
