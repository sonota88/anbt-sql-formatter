# -*- coding: utf-8 -*-

require File.join(File.expand_path(File.dirname(__FILE__)), "helper")

require "anbt-sql-formatter/formatter"


class TestAnbtSqlFormatter < Test::Unit::TestCase
  INDENT_STR = "<-indent->"

  def setup
    @rule = AnbtSql::Rule.new
    @rule.indent_string = INDENT_STR
    @parser = AnbtSql::Parser.new(@rule)

    @fmt = AnbtSql::Formatter.new(@rule)
  end

  def _format(tokens)
    Helper.format_tokens(tokens)
  end

  def token_new(type, string)
    type_map = {
      name: AnbtSql::TokenConstants::NAME,
      space: AnbtSql::TokenConstants::SPACE
    }
    _type = type_map.fetch(type)

    AnbtSql::Token.new(_type, string)
  end


  sub_test_case "modify_keyword_case" do
    test "upper case" do

    @rule.keyword = AnbtSql::Rule::KEYWORD_UPPER_CASE

    tokens = @parser.parse("select")
    @fmt.modify_keyword_case(tokens)
    assert_equal(
      strip_indent(
        <<-EOB
        keyword (SELECT)
        EOB
      ),
      _format(tokens)
    )

    end

    test "lower case" do

    @rule.keyword = AnbtSql::Rule::KEYWORD_LOWER_CASE

    tokens = @parser.parse("SELECT")
    @fmt.modify_keyword_case(tokens)
    assert_equal(
      strip_indent(
        <<-EOB
        keyword (select)
        EOB
      ),
      _format(tokens)
    )

    end
  end


  sub_test_case "concat_operator_for_oracle" do
    test "length is less than 3, should do nothing" do

    tokens = @parser.parse("a+")
    @fmt.concat_operator_for_oracle(tokens)
    assert_equal(
      strip_indent(
        <<-EOB
        name (a)
        symbol (+)
        EOB
      ),
      _format(tokens)
    )

    end

    test "basic" do

    tokens = @parser.parse("(+)")
    @fmt.concat_operator_for_oracle(tokens)
    assert_equal(
      strip_indent(
        <<-EOB
        symbol ((+))
        EOB
      ),
      _format(tokens)
    )

    end

    test "format_list" do

    tokens = @parser.parse("(+)")
    tokens = @fmt.format_list(tokens)
    assert_equal(
      strip_indent(
        <<-EOB
        symbol ((+))
        EOB
      ),
      _format(tokens)
    )

    end
  end


  sub_test_case "remove_symbol_side_space" do
    test "a (b" do

    tokens = @parser.parse("a (b")
    @fmt.remove_symbol_side_space(tokens)
    assert_equal(
      strip_indent(
        <<-EOB
        name (a)
        symbol (()
        name (b)
        EOB
      ),
      _format(tokens)
    )

    end

    test "a( b" do

    tokens = @parser.parse("a( b")
    @fmt.remove_symbol_side_space(tokens)
    assert_equal(
      strip_indent(
        <<-EOB
        name (a)
        symbol (()
        name (b)
        EOB
      ),
      _format(tokens)
    )

    end

    test "a ( b" do

    tokens = @parser.parse("a ( b")
    @fmt.remove_symbol_side_space(tokens)
    assert_equal(
      strip_indent(
        <<-EOB
        name (a)
        symbol (()
        name (b)
        EOB
      ),
      _format(tokens)
    )

    end
  end


  sub_test_case "special_treatment_for_parenthesis_with_one_element" do
    test "one element, should not separate" do

    tokens = @parser.parse("( 1 )")
    @fmt.special_treatment_for_parenthesis_with_one_element(tokens)
    assert_equal(
      strip_indent(
        <<-EOB
        symbol ((1))
        EOB
      ),
      _format(tokens)
    )

    end

    test "more than one element, should separate" do

    tokens = @parser.parse("(1,2)")
    @fmt.special_treatment_for_parenthesis_with_one_element(tokens)
    assert_equal(
      strip_indent(
        <<-EOB
        symbol (()
        value (1)
        symbol (,)
        value (2)
        symbol ())
        EOB
      ),
      _format(tokens)
    )

    end
  end


  sub_test_case "insert_space_between_tokens" do
    test "a=" do

    tokens = @parser.parse("a=")
    @fmt.insert_space_between_tokens(tokens)
    assert_equal(
      strip_indent(
        <<-EOB
        name (a)
        space ( )
        symbol (=)
        EOB
      ),
      _format(tokens)
    )

    end

    test "=b" do

    tokens = @parser.parse("=b")
    @fmt.insert_space_between_tokens(tokens)
    assert_equal(
      strip_indent(
        <<-EOB
        symbol (=)
        space ( )
        name (b)
        EOB
      ),
      _format(tokens)
    )

    end
  end


  sub_test_case "insert_return_and_indent" do
    test "basic" do

    msg = "basic - "
    tokens = @parser.parse("foo bar")

    index, indent_depth = 1, 1

    assert_equals(
      msg + "before",
      strip_indent(
        <<-EOB
        name (foo)
        space ( )
        name (bar)
        EOB
      ),
      _format(tokens)
    )

    result = @fmt.insert_return_and_indent(tokens, index, indent_depth)

    assert_equals(
      msg + "index: #{index} / indent depth: #{indent_depth}",
      strip_indent(
        <<-EOB
        name (foo)
        space (\n#{INDENT_STR})
        name (bar)
        EOB
      ),
      _format(tokens)
    )

    end

    test "replace: after" do

    msg = "replace: after - " # 後の空白を置き換え
    tokens = @parser.parse("select foo")

    index, indent_depth = 1, 1

    assert_equals(
      msg + "before",
      strip_indent(
        <<-EOB
        keyword (select)
        space ( )
        name (foo)
        EOB
      ),
      _format(tokens)
    )

    result = @fmt.insert_return_and_indent(tokens, index, indent_depth)

    assert_equals(
      msg + "#{msg}: index: #{index} / indent depth: #{indent_depth}",
      strip_indent(
        <<-EOB
        keyword (select)
        space (\n#{INDENT_STR})
        name (foo)
        EOB
      ),
      _format(tokens)
    )

    end

    test "replace: before" do

    msg = "replace: before - " # 前の空白を置き換え
    tokens = @parser.parse("select foo")
    index, indent_depth = 2, 1

    assert_equals(
      msg + "before",
      strip_indent(
        <<-EOB
        keyword (select)
        space ( )
        name (foo)
        EOB
      ),
      _format(tokens)
    )

    result = @fmt.insert_return_and_indent(tokens, index, indent_depth)
    assert_equals(
      msg + "", 0, result)

    assert_equals(
      msg + "#{msg}: index: #{index} / indent depth: #{indent_depth}",
      strip_indent(
        <<-EOB
        keyword (select)
        space (\n#{INDENT_STR})
        name (foo)
        EOB
      ),
      _format(tokens)
    )

    end

    test "indent depth = 2" do

    msg = "indent depth = 2 - "
    tokens = @parser.parse("foo bar")
    index, indent_depth = 1, 2

    assert_equals(
      msg + "before",
      strip_indent(
        <<-EOB
        name (foo)
        space ( )
        name (bar)
        EOB
      ),
      _format(tokens)
    )

    result = @fmt.insert_return_and_indent(tokens, index, indent_depth)

    assert_equals(
      msg + "#{msg}: index: #{index} / indent depth: #{indent_depth}",
      strip_indent(
        <<-EOB
        name (foo)
        space (\n#{INDENT_STR}#{INDENT_STR})
        name (bar)
        EOB
      ),
      _format(tokens)
    )

    end

    test "kw, nl, kw" do

    tokens = @parser.parse("select\ncase")

    assert_equal(
      strip_indent(
        <<-EOB
        keyword (select)
        space (\n)
        keyword (case)
        EOB
      ),
      _format(tokens)
    )

    end

    test "insert: return 1" do

    tokens = [
      token_new(:name, "foo"),
      token_new(:name, "bar")
    ]

    index = 1
    result = @fmt.insert_return_and_indent(tokens, index, 1)

    assert_equal(1, result)

    end

    test "replace: return 0" do

    tokens = [
      token_new(:name, "foo"),
      token_new(:space, " "),
      token_new(:name, "bar")
    ]

    index = 2
    result = @fmt.insert_return_and_indent(tokens, index, 1)

    assert_equal(0, result)

    end

    test "out of bounds" do

    tokens = [
      token_new(:name, "foo"),
      token_new(:space, " "),
      token_new(:name, "bar")
    ]

    index = 10
    result = @fmt.insert_return_and_indent(tokens, index, 1)

    assert_equal(0, result)

    end
  end ## insert_return_and_indent


  sub_test_case "format" do
    test "function with parenthesis" do

    func_name = "TEST_FUNCTION"
    @rule.function_names << func_name

    assert_equal(
      strip_indent(
        <<-EOB
        SELECT
        <-indent-><-indent->#{func_name}( * )
        EOB
      ),
      @fmt.format("select #{func_name}(*)")
    )

    @rule.function_names.delete func_name

    end

    test "Next line of single comment" do

    assert_equal(
      strip_indent(
        <<-EOB
        SELECT
        <-indent-><-indent->-- comment
        <-indent-><-indent->name
        EOB
      ),
      @fmt.format(strip_indent(
        <<-EOB
        select
        -- comment
        name
        EOB
      ))
    )

    end

    test "new line after single line comment" do

    assert_equal(
      strip_indent(
        <<-EOB
        --a
        b
        EOB
      ),
      @fmt.format(strip_indent(
        <<-EOB
        --a
        b
        EOB
      ))
    )

    end

    test "two line breaks after semicolon" do

    assert_equal(
      strip_indent(
        <<-EOB
        a
        ;

        b
        EOB
      ),
      @fmt.format(strip_indent(
        <<-EOB
        a;b
        EOB
      ))
    )

    end

    test "no line breaks after semicolon" do

    assert_equal(
      strip_indent(
        <<-EOB
        a
        ;
        EOB
      ),
      @fmt.format("a;")
    )

    end
  end

  def test_format_between
    assert_equals(
      "should not add a new line to 'BETWEEN ... AND ...'",
      strip_indent(
        <<-EOB
        BETWEEN 0 AND 1
        EOB
      ),
      @fmt.format("between 0 and 1")
    )
  end


  sub_test_case "split_to_statements" do
    test "a;b" do

    tokens = @parser.parse("a;b")
    statements = @fmt.split_to_statements(tokens)

    assert_equal(2, statements.size)
    assert_equal(
      "name (a)",
      _format( statements[0] )
    )
    assert_equal(
      "name (b)",
      _format( statements[1] )
    )

    end

    test ";" do

    tokens = @parser.parse(";")
    statements = @fmt.split_to_statements(tokens)
    assert_equal(
      [],
      statements[0]
    )
    assert_equal(
      [],
      statements[1]
    )

    end

    test "a;" do

    tokens = @parser.parse("a;")
    statements = @fmt.split_to_statements(tokens)
    assert_equal(
      "name (a)",
      _format( statements[0] )
    )
    assert_equal(
      [],
      statements[1]
    )

    end

    test ";a" do

    tokens = @parser.parse(";a")
    statements = @fmt.split_to_statements(tokens)
    assert_equal(
      [],
      statements[0]
    )
    assert_equal(
      "name (a)",
      _format( statements[1] )
    )

    end
  end
end
