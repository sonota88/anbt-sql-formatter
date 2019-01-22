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
  def test_next_sql_token
    msg = "token type recognition"

    ########
    @parser.before = " "
    @parser.pos = 0
    assert_equals(
      msg + "space",
      strip_indent(
        <<-EOB
        space ( )
        EOB
      ),
      _format([ @parser.next_sql_token ])
    )

    ########
    @parser.before = "!="
    @parser.pos = 0
    assert_equals(
      msg + "!=",
      strip_indent(
        <<-EOB
        symbol (!=)
        EOB
      ),
      _format([ @parser.next_sql_token ])
    )


    ########
    @parser.before = "a b"
    @parser.pos = 1
    assert_equals(
      msg + "space",
      strip_indent(
        <<-EOB
        space ( )
        EOB
      ),
      _format([ @parser.next_sql_token ])
    )

    ########
    @parser.before = ","
    @parser.pos = 0
    assert_equals(
      msg + "symbol",
      strip_indent(
        <<-EOB
        symbol (,)
        EOB
      ),
      _format([ @parser.next_sql_token ])
    )

    ########
    @parser.before = "select"
    @parser.pos = 0
    assert_equals(
      msg + "keyword: select",
      strip_indent(
        <<-EOB
        keyword (select)
        EOB
      ),
      _format([ @parser.next_sql_token ])
    )

    ########
    @parser.before = "case"
    @parser.pos = 0
    assert_equals(
      msg + "keyword: case",
      strip_indent(
        <<-EOB
        keyword (case)
        EOB
      ),
      _format([ @parser.next_sql_token ])
    )

    ########
    @parser.before = "xxx123"
    @parser.pos = 0
    assert_equals(
      msg + "name",
      strip_indent(
        <<-EOB
        name (xxx123)
        EOB
      ),
      _format([ @parser.next_sql_token ])
    )

    ########
    @parser.before = '123'
    @parser.pos = 0
    assert_equals(
      msg + "value",
      strip_indent(
        <<-EOB
        value (123)
        EOB
      ),
      _format([ @parser.next_sql_token ])
    )

    ########
    @parser.before = '1.23'
    @parser.pos = 0
    assert_equals(
      msg + "value",
      strip_indent(
        <<-EOB
        value (1.23)
        EOB
      ),
      _format([ @parser.next_sql_token ])
    )

    ########
    @parser.before = '-1.23 '
    @parser.pos = 0
    assert_equals(
      msg + "value",
      strip_indent(
        <<-EOB
        value (-1.23)
        EOB
      ),
      _format([ @parser.next_sql_token ])
    )

    ########
    @parser.before = '1.23e45 '
    @parser.pos = 0
    assert_equals(
      msg + "value",
      strip_indent(
        <<-EOB
        value (1.23e45)
        EOB
      ),
      _format([ @parser.next_sql_token ])
    )

    ########
    @parser.before = '1.23e-45 '
    @parser.pos = 0
    assert_equals(
      msg + "value",
      strip_indent(
        <<-EOB
        value (1.23e-45)
        EOB
      ),
      _format([ @parser.next_sql_token ])
    )

    ########
    @parser.before = '-1.23e-45 '
    @parser.pos = 0
    assert_equals(
      msg + "value",
      strip_indent(
        <<-EOB
        value (-1.23e-45)
        EOB
      ),
      _format([ @parser.next_sql_token ])
    )

    ########
    @parser.before = '0x01 '
    @parser.pos = 0
    assert_equals(
      msg + "value",
      strip_indent(
        <<-EOB
        value (0x01)
        EOB
      ),
      _format([ @parser.next_sql_token ])
    )

    ########
    @parser.before = '1x'
    @parser.pos = 0
    assert_equals(
      msg + "value",
      strip_indent(
        <<-EOB
        value (1)
        EOB
      ),
      _format([ @parser.next_sql_token ])
    )
  end


  def test_parser
    msg = "parser basic case - "

    ########
    assert_equals(
      msg + "",
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

    ########
    assert_equals(
      msg + "double-quoted schema and table",
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

    ########
    assert_equals(
      msg + "minus + non-number",
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

    ########
    assert_equals(
      msg + "minus + non-number",
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

    ########
    assert_equals(
      msg + "single comment",
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

    ########
    assert_equals(
      msg + "parenthesis in single quote",
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

    ########
    assert_equals(
      msg + "parenthesis in double quote",
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

    ########
    assert_equals(
      msg + "multiple line comment: 1",
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

    ########
    assert_equals(
      msg + "multiple line comment: 2",
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

    ########
    assert_equals(
      msg + "invalid paired double quote",
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

    ########
    assert_equals(
      msg + "multiwords keyword",
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

    ########
    assert_equals(
      msg + "multiwords keyword 2",
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

    ########
    assert_equals(
      msg + "multiwords keyword 3",
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

    ########
    assert_equals(
      msg + "multiwords keyword 4",
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
