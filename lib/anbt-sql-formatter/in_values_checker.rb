class AnbtSql
  class InValuesChecker
    def initialize(rule)
      if rule.in_values_num.nil?
        @mode = :default
      elsif rule.in_values_num == AnbtSql::Rule::ONELINE_IN_VALUES_NUM
        @mode = :oneline
        @num = rule.in_values_num
      else
        @mode = :compact
        @num = rule.in_values_num
        @counter = 0
      end
    end

    def check
      if @mode == :default
        true
      elsif @mode == :oneline
        false
      else
        @counter += 1
        if @counter == @num
          @counter = 0
          true
        else
          false
        end
      end
    end
  end
end
