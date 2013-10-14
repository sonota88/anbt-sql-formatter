# -*- coding: utf-8 -*-

require File.join(File.expand_path(File.dirname(__FILE__)), "helper")

require "anbt-sql-formatter/helper"
require "anbt-sql-formatter/exception"


class TestAnbtSqlHelper < Test::Unit::TestCase
  def setup
  end

  # Java版では List を使っている
  def test_array_get
    arr = %w(a b c) # index = 0, 1, 2
    assert_raise(IndexOutOfBoundsException, "値が範囲外なのに例外が発生しない"){
      ::AnbtSql::ArrayUtil.get(arr, 3)
    }
    assert_raise(IndexOutOfBoundsException, "値が範囲外なのに例外が発生しない"){
      ::AnbtSql::ArrayUtil.get(arr, -1)
    }
  end
end
