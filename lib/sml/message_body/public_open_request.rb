module Sml
  module MessageBody
    class PublicOpenRequest
      attr_reader :codepage, :client_id, :request_file_id, :server_id,
                  :username, :password, :sml_version

      def initialize(tree)
        @codepage        = tree[0]
        @client_id       = tree[1]
        @request_file_id = tree[2]
        @server_id       = tree[3]
        @username        = tree[4]
        @password        = tree[5]
        @sml_version     = tree[6]
      end
    end
  end
end
