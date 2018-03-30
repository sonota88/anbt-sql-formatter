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

  def test_modify_keyword_case
    msg = "upcase"

    ########
    @rule.keyword = AnbtSql::Rule::KEYWORD_UPPER_CASE

    tokens = @parser.parse("select")
    @fmt.modify_keyword_case(tokens)
    assert_equals(
      msg + "",
      strip_indent(
        <<-EOB
        keyword (SELECT)
        EOB
      ),
      _format(tokens)
    )

    ########
    msg = "downcase"
    @rule.keyword = AnbtSql::Rule::KEYWORD_LOWER_CASE

    tokens = @parser.parse("SELECT")
    @fmt.modify_keyword_case(tokens)
    assert_equals(
      msg + "",
      strip_indent(
        <<-EOB
        keyword (select)
        EOB
      ),
      _format(tokens)
    )
  end


  def test_concat_operator_for_oracle
    msg = "concat_operator_for_oracle - "

    ########
    tokens = @parser.parse("a+")
    @fmt.concat_operator_for_oracle(tokens)
    assert_equals(
      msg + "length is less than 3, should do nothing",
      strip_indent(
        <<-EOB
        name (a)
        symbol (+)
        EOB
      ),
      _format(tokens)
    )

    ########
    tokens = @parser.parse("(+)")
    @fmt.concat_operator_for_oracle(tokens)
    assert_equals(
      msg + "",
      strip_indent(
        <<-EOB
        symbol ((+))
        EOB
      ),
      _format(tokens)
    )

    ########
    tokens = @parser.parse("(+)")
    tokens = @fmt.format_list(tokens)
    assert_equals(
      msg + "format_list()",
    strip_indent(
        <<-EOB
        symbol ((+))
        EOB
      ),
      _format(tokens)
    )
  end

  
  def test_remove_symbol_side_space
    msg = "remove_symbol_side_space - "
    
    ########
    tokens = @parser.parse("a (b")
    @fmt.remove_symbol_side_space(tokens)
    assert_equals(
      msg + "",
      strip_indent(
        <<-EOB
        name (a)
        symbol (()
        name (b)
        EOB
      ),
      _format(tokens)
    )


    ########
    tokens = @parser.parse("a( b")
    @fmt.remove_symbol_side_space(tokens)
    assert_equals(
      msg + "", strip_indent(
        <<-EOB
        name (a)
        symbol (()
        name (b)
        EOB
      ),
      _format(tokens)
    )


    ########
    tokens = @parser.parse("a ( b")
    @fmt.remove_symbol_side_space(tokens)
    assert_equals(
      msg + "",
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
 

  def test_special_treatment_for_parenthesis_with_one_element
    msg = "special_treatment_for_parenthesis_with_one_element - "
    
    ########
    tokens = @parser.parse("( 1 )")
    @fmt.special_treatment_for_parenthesis_with_one_element(tokens)
    assert_equals(
      msg + "one element, should not separate",
      strip_indent(
        <<-EOB
        symbol ((1))
        EOB
      ),
      _format(tokens)
    )


    ########
    tokens = @parser.parse("(1,2)")
    @fmt.special_treatment_for_parenthesis_with_one_element(tokens)
    assert_equals(
      msg + "more than one element, should separate",
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
 

  def test_insert_space_between_tokens
    msg = "insert_space_between_tokens - "

    ########
    tokens = @parser.parse("a=")
    @fmt.insert_space_between_tokens(tokens)
    assert_equals(msg,
      strip_indent(
        <<-EOB
        name (a)
        space ( )
        symbol (=)
        EOB
      ),
      _format(tokens)
    )
  
    ########
    tokens = @parser.parse("=b")
    @fmt.insert_space_between_tokens(tokens)
    assert_equals(msg,
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

  
  def test_insert_return_and_indent
    msg = "insert_return_and_indent - "

    ########
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

    ########
    # msg = "" #"後の空白を置き換え"
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

    ########
    msg = "" #"前の空白を置き換え"
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

    ########
    msg = "indent depth = 2"
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

    ########
    msg = "kw, nl, kw"
    tokens = @parser.parse("select\ncase")

    assert_equals(
      msg + "",
      strip_indent(
        <<-EOB
        keyword (select)
        space (\n)
        keyword (case)
        EOB
      ),
      _format(tokens)
    )

    ########
=begin
    msg = "FROM の前で改行"

    assert_equals(
      msg + "",
      strip_indent(
        <<-EOB
        SELECT
        <-indent-><-indent->aa
        <-indent-><-indent->,bb
        <-indent-><-indent->,cc
        <-indent-><-indent->,dd
        <-indent-><-indent->,ee
        <-indent->FROM
        <-indent-><-indent->foo
        ;
        EOB
      ),
#       _format(tokens),
      @fmt.format("SELECT aa ,bb ,cc ,dd ,ee FROM foo;")
    )
=end

    # ########
    # msg = "指定した index に対して tokens[index] が存在するので 1 を返すべき"
    # 間違い。tokens[index] が存在していても 1 を返すとは限らない。
    # tokens = parser.parse("foo bar")
    # #pp tokens
    # index = 1
    # result = @fmt.insert_return_and_indent(tokens, index, 1)
    
    # assert_equals(msg + "", 1, result, msg)

    ########
    msg = "指定した index に対して tokens[index] が存在しないので 0 を返すべき"
    tokens = @parser.parse("foo bar")

    index = 10
    result = @fmt.insert_return_and_indent(tokens, index, 1)
    
    assert_equals(msg + "", 0, result)
  end ## insert_return_and_indent


  def test_format
    msg = "format - "

    ########
    func_name = "TEST_FUNCTION"
    @rule.function_names << func_name
    
    assert_equals(
      msg + "function with parenthesis",
      strip_indent(
        <<-EOB
        SELECT
        <-indent-><-indent->#{func_name}( * )
        EOB
      ),
      @fmt.format("select #{func_name}(*)")
    )
    
    @rule.function_names.delete func_name
    
    ########
    assert_equals(
      msg + "Next line of single commnet",
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

    ########
    assert_equals(
      msg + "new line after single line comment",
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
    );

    ########
    assert_equals(
      msg + "two line breaks after semicolon",
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
    );

    ########
    assert_equals(
      msg + "two line breaks after semicolon",
      strip_indent(
        <<-EOB
        a
        ;
        EOB
      ),
      @fmt.format("a;")
    )
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


  def test_split_to_statements
    msg = "split_to_statements - "

    ########
    tokens = @parser.parse("a;b")

    assert_equals(
      msg + "first statement",
      "a",
      @fmt.split_to_statements(tokens)[0][0].string
    )
    assert_equals(
      msg + "second statement",
      "b",
      @fmt.split_to_statements(tokens)[1][0].string
    )

    ########
    tokens = @parser.parse(";")
    statements = @fmt.split_to_statements(tokens)
    assert_equals(
      msg,
      [],
      statements[0]
    )
    assert_equals(
      msg,
      [],
      statements[1]
    )

    ########
    tokens = @parser.parse("a;")
    statements = @fmt.split_to_statements(tokens)
    assert_equals(
      msg,
      "name (a)",
      _format( statements[0] )
    )
    assert_equals(
      msg,
      [],
      statements[1]
    )

    ########
    tokens = @parser.parse(";a")
    statements = @fmt.split_to_statements(tokens)
    assert_equals(
      msg,
      [],
      statements[0]
    )
    assert_equals(
      msg,
      "name (a)",
      _format( statements[1] )
    )

    ########
    tokens = @parser.parse("a;b")
    statements = @fmt.split_to_statements(tokens)
    assert_equals(
      msg,
      "name (a)",
      _format( statements[0] )
    )
    assert_equals(
      msg,
      "name (b)",
      _format( statements[1] )
    )
  end
end
