# -*- coding: utf-8 -*-

require File.join(File.expand_path(File.dirname(__FILE__)), "helper")

require "anbt-sql-formatter/helper"
require "anbt-sql-formatter/rule"


class TestAnbtSqlRule < Test::Unit::TestCase
  def setup
    @rule = AnbtSql::Rule.new
  end

  def test_function?
    msg = "function? - "

    func_name = "TEST_FUNCTION"
    @rule.function_names << func_name
    assert_equals(
      msg,
      true,
      @rule.function?(func_name)
    )

    @rule.function_names.delete(func_name)
    assert_equals(
      msg,
      false,
      @rule.function?(func_name)
    )
  end
end
