module Sml
  module MessageBody
    class PublicOpenResponse
      attr_reader :codepage, :client_id, :request_file_id, :server_id,
                  :reference_time, :sml_version

      def initialize(tree)
        @codepage        = tree[0]
        @client_id       = tree[1]
        @request_file_id = tree[2]
        @server_id       = tree[3]
        @reference_time  = Sml::Time.from_tree(tree[4])
        @sml_version     = tree[5]
      end

      def to_s
        "<Body PORes T: #{reference_time} RF: #{request_file_id.inspect} S: #{server_id.inspect} V: #{sml_version.inspect}>"
      end
    end
  end
end
