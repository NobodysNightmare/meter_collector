require 'optparse'

class MeterCollector
  module Cli
    class Options
      attr_reader :config_file, :mode

      def initialize
        @config_file = nil
        @mode = :print
      end

      def parse!(args)
        parser.parse(args)
      end

      def validate!
        return if @config_file

        validation_error('Specifying a configuration file is required.')
      end

      private

      # rubocop:disable Metrics/MethodLength
      def parser
        OptionParser.new do |p|
          p.banner = 'Usage: meter_collector -f FILE [options]'
          p.separator ''

          p.on('-f', '--file CONFIG', 'Path to a configuration file') do |file|
            @config_file = file
          end

          p.on('-u', '--upload', 'Upload values to configured server, instead of just printing them') do |bool|
            @mode = bool ? :upload : :print
          end

          p.on_tail('-h', '--help', 'Show this help message') do
            puts p
            exit
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

      def validation_error(message)
        puts message
        puts
        puts 'For more details see:'
        puts
        puts '  meter_collector --help'
        puts
        exit(-1)
      end
    end
  end
end
