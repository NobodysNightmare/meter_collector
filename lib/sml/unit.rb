module Sml
  class Unit
    UNITS = {
      25 => ['energy', 'J', 'joule']
      27 => ['active power', 'W', 'watt']
      28 => ['apparent power', 'VA', 'volt-ampere']
      30 => ['active energy', 'Wh', 'watt-hour']
      31 => ['apparent energy', 'VAh', 'volt-ampere-hour']
    }

    class << self
      def from_tree(tree)
        params = UNITS[tree]
        raise ArgumentError, "Unknown unit '#{tree}'" if params.nil?

        new(*params)
      end
    end

    attr_reader :quantity, :short, :human

    def initialize(quantity, short, human)
      @quantity = quantity
      @short = short
      @human = human
    end
  end
end
