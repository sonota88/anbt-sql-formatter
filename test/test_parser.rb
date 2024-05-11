# -*- coding: utf-8 -*-

require File.join(File.expand_path(File.dirname(__FILE__)), "helper")

require "anbt-sql-formatter/rule"
require "anbt-sql-formatter/parser"


class AnbtSql
  class Parser
    attr_accessor :before, :pos
  end
end


class TestAnbtSqlParser < Test::Unit::TestCase
  def setup
    @parser = AnbtSql::Parser.new(AnbtSql::Rule.new)
  end

  def _format(tokens)
    Helper.format_tokens(tokens)
  end


  def test_space?
    msg = "space? - "
    assert_equals( msg, true, @parser.space?(" ") )
    assert_equals( msg, true, @parser.space?("\t") )
    assert_equals( msg, true, @parser.space?("\r") )
    assert_equals( msg, true, @parser.space?("\n") )
  end


  def test_letter?
    msg = "letter? - "
    assert_equals( msg, false, @parser.letter?("'") )
    assert_equals( msg, false, @parser.letter?('"') )
  end


  def test_symbol?
    msg = "symbol?"
    assert_equals( msg, true, @parser.symbol?('"') )
    assert_equals( msg, true, @parser.symbol?("'") )
    assert_equals( msg, true, @parser.symbol?("!") )
  end


  def test_digit?
    msg = "digit?"
    assert_equals( msg, true,  @parser.digit?("0") )
    assert_equals( msg, true,  @parser.digit?("5") )
    assert_equals( msg, true,  @parser.digit?("9") )
    assert_equals( msg, false, @parser.digit?("a") )
  end


  ##
  # コメントと文字列のテストは coarse tokenize で行う。
  def test_next_sql_token_pos
    msg = "token pos"

    @parser.before = " "
    @parser.pos = 0
    token = @parser.next_sql_token
    assert_equals(msg,
                  0, token.pos)

    @parser.before = "a b"
    @parser.pos = 1
    token = @parser.next_sql_token
    assert_equals(msg,
                  1, token.pos)
  end


  ##
  # コメントと文字列のテストは coarse tokenize で行う。
  sub_test_case "next_sql_token" do
    test "space 010" do
      @parser.before = " "
      @parser.pos = 0
      assert_equal(
        strip_indent(
          <<-EOB
          space ( )
          EOB
        ),
        _format([ @parser.next_sql_token ])
      )
    end

    test "symbol 010" do
      @parser.before = "!="
      @parser.pos = 0
      assert_equal(
        strip_indent(
          <<-EOB
          symbol (!=)
          EOB
        ),
        _format([ @parser.next_sql_token ])
      )
    end

    test "pos = 1" do
      @parser.before = "a b"
      @parser.pos = 1
      assert_equal(
        strip_indent(
          <<-EOB
          space ( )
          EOB
        ),
        _format([ @parser.next_sql_token ])
      )
    end

    test "symbol 020" do
      @parser.before = ","
      @parser.pos = 0
      assert_equal(
        strip_indent(
          <<-EOB
          symbol (,)
          EOB
        ),
        _format([ @parser.next_sql_token ])
      )
    end

    test "keyword 010" do
      @parser.before = "select"
      @parser.pos = 0
      assert_equal(
        strip_indent(
          <<-EOB
          keyword (select)
          EOB
        ),
        _format([ @parser.next_sql_token ])
      )
    end

    test "keyword 020" do
      @parser.before = "case"
      @parser.pos = 0
      assert_equal(
        strip_indent(
          <<-EOB
          keyword (case)
          EOB
        ),
        _format([ @parser.next_sql_token ])
      )
    end

    test "name 010" do
      @parser.before = "xxx123"
      @parser.pos = 0
      assert_equal(
        strip_indent(
          <<-EOB
          name (xxx123)
          EOB
        ),
        _format([ @parser.next_sql_token ])
      )
    end

    test "value 010" do
      @parser.before = '123'
      @parser.pos = 0
      assert_equal(
        strip_indent(
          <<-EOB
          value (123)
          EOB
        ),
        _format([ @parser.next_sql_token ])
      )
    end

    test "value 020" do
      @parser.before = '1.23'
      @parser.pos = 0
      assert_equal(
        strip_indent(
          <<-EOB
          value (1.23)
          EOB
        ),
        _format([ @parser.next_sql_token ])
      )
    end

    test "value 030" do
      @parser.before = '-1.23 '
      @parser.pos = 0
      assert_equal(
        strip_indent(
          <<-EOB
          value (-1.23)
          EOB
        ),
        _format([ @parser.next_sql_token ])
      )
    end

    test "value 040" do
      @parser.before = '1.23e45 '
      @parser.pos = 0
      assert_equal(
        strip_indent(
          <<-EOB
          value (1.23e45)
          EOB
        ),
        _format([ @parser.next_sql_token ])
      )
    end

    test "value 050" do
      @parser.before = '1.23e-45 '
      @parser.pos = 0
      assert_equal(
        strip_indent(
          <<-EOB
          value (1.23e-45)
          EOB
        ),
        _format([ @parser.next_sql_token ])
      )
    end

    test "value 060" do
      @parser.before = '-1.23e-45 '
      @parser.pos = 0
      assert_equal(
        strip_indent(
          <<-EOB
          value (-1.23e-45)
          EOB
        ),
        _format([ @parser.next_sql_token ])
      )
    end

    test "value 070" do
      @parser.before = '0x01 '
      @parser.pos = 0
      assert_equal(
        strip_indent(
          <<-EOB
          value (0x01)
          EOB
        ),
        _format([ @parser.next_sql_token ])
      )
    end

    test "value 080" do
      @parser.before = '1x'
      @parser.pos = 0
      assert_equal(
        strip_indent(
          <<-EOB
          value (1)
          EOB
        ),
        _format([ @parser.next_sql_token ])
      )
    end
  end


  sub_test_case "parser" do
    test "basic case" do
      assert_equal(
        strip_indent(
          <<-EOB
          keyword (select)
          space ( )
          name (a)
          space ( )
          keyword (from)
          space ( )
          name (b)
          symbol (;)
          EOB
        ),
        _format( @parser.parse( strip_indent(
          <<-EOB
          select a from b;
          EOB
        )))
      )
    end

    test "double-quoted schema and table" do
      assert_equal(
        strip_indent(
          <<-EOB
          name ("admin"."test")
          EOB
        ),
        _format( @parser.parse( strip_indent(
          <<-EOB
          "admin"."test"
          EOB
        )))
      )
    end

    test "name with dot" do
      assert_equal(
        strip_indent(
          <<-EOB
          name ("admin"."test")
          EOB
        ),
        _format( @parser.parse( strip_indent(
          <<-EOB
          "admin"."test"
          EOB
        )))
      )
    end

    test "minus + non-number" do
      assert_equal(
        strip_indent(
          <<-EOB
          symbol (-)
          name (a)
          EOB
        ),
        _format( @parser.parse( strip_indent(
          <<-EOB
          -a
          EOB
        )))
      )
    end

    test "single comment" do
      assert_equal(
        strip_indent(
          <<-EOB
          keyword (select)
          space (\n)
          comment (-- x)
          name (a)
          EOB
        ),
        _format( @parser.parse(strip_indent(
          <<-EOB
          select
          -- x
          a
          EOB
        )))
      )
    end

    test "parenthesis in single quote" do
      assert_equal(
        strip_indent(
          <<-EOB
          value ('()')
          EOB
        ),
        _format( @parser.parse(strip_indent(
          <<-EOB
          '()'
          EOB
        )))
      )
    end

    test "parenthesis in double quote" do
      assert_equal(
        strip_indent(
          <<-EOB
          name ("()")
          EOB
        ),
        _format( @parser.parse(strip_indent(
          <<-EOB
          "()"
          EOB
        )))
      )
    end

    test "multiple line comment: 1" do
      assert_equal(
        strip_indent(
          <<-EOB
          name (aa)
          comment (/*bb*/)
          name (cc)
          EOB
        ),
        _format( @parser.parse(strip_indent(
          <<-EOB
          aa/*bb*/cc
          EOB
        )))
      )
    end

    test "multiple line comment: 2" do
      assert_equal(
        strip_indent(
          <<-EOB
          name (aa)
          comment (/*b
          b*/)
          name (cc)
          EOB
        ),
        _format( @parser.parse(strip_indent(
          <<-EOB
          aa/*b
          b*/cc
          EOB
        )))
      )
    end

    test "invalid paired double quote" do
      assert_equal(
        strip_indent(
          <<-EOB
          name (aa)
          name ("bb)
          EOB
        ),
        _format( @parser.parse(strip_indent(
          <<-EOB
          aa"bb
          EOB
        )))
      )
    end

    test "multiwords keyword" do
      assert_equal(
        strip_indent(
          <<-EOB
          keyword (group by)
          EOB
        ),
        _format( @parser.parse(strip_indent(
          <<-EOB
          group by
          EOB
        )))
      )
    end

    test "multiwords keyword 2" do
      assert_equal(
        strip_indent(
          <<-EOB
          name (a)
          space ( )
          keyword (group by)
          space ( )
          name (B)
          EOB
        ),
        _format( @parser.parse(strip_indent(
          <<-EOB
          a group by B
          EOB
        )))
      )
    end

    test "multiwords keyword 3" do
      assert_equal(
        strip_indent(
          <<-EOB
          keyword (select)
          space ( )
          value ('group by')
          EOB
        ),
        _format( @parser.parse(strip_indent(
          <<-EOB
          select 'group by'
          EOB
        )))
      )
    end

    test "multiwords keyword 4" do
      assert_equal(
        strip_indent(
          <<-EOB
          keyword (select)
          space ( )
          comment (/*group by*/)
          EOB
        ),
        _format( @parser.parse(strip_indent(
          <<-EOB
          select /*group by*/
          EOB
        )))
      )
    end
  end
end
