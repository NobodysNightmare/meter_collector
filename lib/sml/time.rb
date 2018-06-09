require 'date'

module Sml
  class Time
    TIME_CONVERSIONS = {
      1 => ->(t) { t },
      2 => ->(t) { Time.at(t) },
      3 => ->(t) { Time.at(t[0]).getlocal(60 * (t[1] + t[2])) }
    }

    class << self
      def from_tree(tree)
        # Optional values are represented as empty strings if they are missing
        return nil if tree.is_a?(String) && tree.size == 0

        validate_choice!(tree)
        type = tree[0]
        TIME_CONVERSIONS[type].call(tree[1])
      end

      private

      def validate_choice!(tree)
        type = tree[0]
        raise "Unknown time tag #{type.to_s(16)}" unless TIME_CONVERSIONS.key?(type)
      end
    end
  end
end
