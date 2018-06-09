require 'sml/time'

require 'sml/message_body/public_open_request'
require 'sml/message_body/public_open_response'

module Sml
  module MessageBody
    BODY_TYPES = {
      0x00000100 => MessageBody::PublicOpenRequest,
      0x00000101 => MessageBody::PublicOpenResponse
    }

    class << self
      def from_tree(tree)
        validate_choice!(tree)

        type = tree[0]
        BODY_TYPES[type].new(tree[1])
      end

      private

      def validate_choice!(tree)
        body_type = tree[0]
        raise "Unknown body type #{body_type.to_s(16)}" unless BODY_TYPES.key?(body_type)
        raise "Expected second choice element to be a structure" unless tree[1].is_a? Array
      end
    end
  end
end
