require 'sml/message_body'

module Sml
  class Message
    attr_reader :transaction_id, :group_number, :abort_on_error, :body, :crc

    def initialize(tree)
      expect_message_structure!(tree)
      @transaction_id = tree[0]
      @group_number   = tree[1]
      @abort_on_error = tree[2]
      @body           = MessageBody.from_tree(tree[3])
      @crc            = tree[4]
    end

    def to_s
      "<Sml Message T:#{transaction_id.inspect} G:#{group_number} #{body}>"
    end

    private

    def expect_message_structure!(tree)
      raise "Expected message structure of length 6, got #{tree.size}" unless tree.size == 6
      raise 'No end of sml message found' unless tree[5].nil?
    end
  end
end
