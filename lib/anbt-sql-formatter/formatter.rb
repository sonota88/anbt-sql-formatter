# -*- coding: utf-8 -*-

require "anbt-sql-formatter/rule"
require "anbt-sql-formatter/parser"
require "anbt-sql-formatter/exception"
require "anbt-sql-formatter/in_values_checker"
require "anbt-sql-formatter/helper" # Stack


class AnbtSql
  class Formatter

    include StringUtil

    @rule = nil

    def initialize(rule)
      @rule = rule
      @parser = AnbtSql::Parser.new(@rule)

      # 丸カッコが関数のものかどうかを記憶
      @function_bracket = Stack.new
    end


    def split_to_statements(tokens)
      statements = []
      buf = []
      tokens.each{|token|
        if token.string == ";"
          statements << buf
          buf = []
        else
          buf << token
        end
      }

      statements << buf

      statements
    end


    ##
    # 与えられたSQLを整形した文字列を返します。
    #
    # 改行で終了するSQL文は、整形後も改行付きであるようにします。
    # sql_str:: 整形前のSQL文
    def format(sql_str)
      @function_bracket.clear()
      begin
        is_sql_ends_with_new_line = false
        if sql_str.end_with?("\n")
          is_sql_ends_with_new_line = true
        end

        tokens = @parser.parse(sql_str)

        statements = split_to_statements(tokens)

        statements = statements.map{|inner_tokens|
          format_list(inner_tokens)
        }

        # 変換結果を文字列に戻す。
        after = statements.map{|inner_tokens|
          inner_tokens.map{ |t| t.string }.join("")
        }.join("\n;\n\n").sub( /\n\n\Z/, "" )

        after += "\n" if is_sql_ends_with_new_line

        return after
      rescue => e
        raise AnbtSql::FormatterException.new, e.message, e.backtrace
      end
    end


    def modify_keyword_case(tokens)
      # SQLキーワードは大文字とする。or ...
      tokens.each{ |token|
        next if token._type != AnbtSql::TokenConstants::KEYWORD

        case @rule.keyword
        when AnbtSql::Rule::KEYWORD_NONE
          ;
        when AnbtSql::Rule::KEYWORD_UPPER_CASE
          token.string.upcase!
        when AnbtSql::Rule::KEYWORD_LOWER_CASE
          token.string.downcase!
        end
      }
    end


    ##
    # .
    #  ["(", "+", ")"] => ["(+)"]
    def concat_operator_for_oracle(tokens)
      index = 0
      # Length of tokens changes in loop!
      while index < tokens.size - 2
        if (tokens[index    ].string == "(" &&
            tokens[index + 1].string == "+" &&
            tokens[index + 2].string == ")")
          tokens[index].string = "(+)"
          ArrayUtil.remove(tokens, index + 1)
          ArrayUtil.remove(tokens, index + 1)
        end
        index += 1
      end
    end


    def remove_symbol_side_space(tokens)
      prev_token = nil

      (tokens.size - 1).downto(1){|index|
        token     = ArrayUtil.get(tokens, index)
        prev_token = ArrayUtil.get(tokens, index - 1)

        if (token._type == AnbtSql::TokenConstants::SPACE &&
            (prev_token._type == AnbtSql::TokenConstants::SYMBOL ||
             prev_token._type == AnbtSql::TokenConstants::COMMENT))
          ArrayUtil.remove(tokens, index)
        elsif ((token._type == AnbtSql::TokenConstants::SYMBOL ||
                token._type == AnbtSql::TokenConstants::COMMENT) &&
               prev_token._type == AnbtSql::TokenConstants::SPACE)
          ArrayUtil.remove(tokens, index - 1)
        elsif (token._type == AnbtSql::TokenConstants::SPACE)
          token.string = " "
        end
      }
    end


    def insert_space_between_tokens(tokens)
      index = 1

      # Length of tokens changes in loop!
      while index < tokens.size
        prev  = ArrayUtil.get(tokens, index - 1)
        token = ArrayUtil.get(tokens, index    )

        if (prev._type  != AnbtSql::TokenConstants::SPACE &&
            token._type != AnbtSql::TokenConstants::SPACE)
          # カンマの後にはスペース入れない
          if not @rule.space_after_comma
            if prev.string == ","
              index += 1 ; next
            end
          end

          # 関数名の後ろにはスペースは入れない
          # no space after function name
          if (@rule.function?(prev.string) &&
              token.string == "(")
            index += 1 ; next
          end

          ArrayUtil.add(tokens, index,
                     AnbtSql::Token.new(AnbtSql::TokenConstants::SPACE, " ")
                     )
        end
        index += 1
      end
    end


    def format_list_main_loop(tokens)
      # インデントを整える。
      indent = 0
      # 丸カッコのインデント位置を覚える。
      bracket_indent = Stack.new

      prev = AnbtSql::Token.new(AnbtSql::TokenConstants::SPACE,
                                  " ")

      encounter_between = false
      in_values_checker = nil

      index = 0
      # Length of tokens changes in loop!
      while index < tokens.size
        token = ArrayUtil.get(tokens, index)

        if token._type == AnbtSql::TokenConstants::SYMBOL

          # indentを１つ増やし、'('のあとで改行。
          if token.string == "("
            @function_bracket.push( @rule.function?(prev.string) ? true : false )
            bracket_indent.push(indent)
            indent += 1
            index += insert_return_and_indent(tokens, index + 1, indent)

            # indentを１つ増やし、')'の前と後ろで改行。
          elsif token.string == ")"
            indent = (bracket_indent.pop()).to_i
            index += insert_return_and_indent(tokens, index, indent)
            @function_bracket.pop()

            # ','の前で改行
          elsif token.string == ","
            if in_values_checker.nil? || in_values_checker.check()
              index += insert_return_and_indent(tokens, index, indent, "x")
            end

          elsif token.string == ";"
            # 2005.07.26 Tosiki Iga とりあえずセミコロンでSQL文がつぶれないように改良
            indent = 0
            index += insert_return_and_indent(tokens, index, indent)
          end

        elsif token._type == AnbtSql::TokenConstants::KEYWORD
          in_values_checker = nil if in_values_checker

          in_values_checker = AnbtSql::InValuesChecker.new(@rule) if equals_ignore_case(token.string, "IN")

          # indentを２つ増やし、キーワードの後ろで改行
          if (equals_ignore_case(token.string, "DELETE") ||
              equals_ignore_case(token.string, "SELECT") ||
              equals_ignore_case(token.string, "UPDATE")   )
            indent += 2
            index += insert_return_and_indent(tokens, index + 1, indent, "+2")
          end

          # indentを１つ増やし、キーワードの後ろで改行
          if @rule.kw_plus1_indent_x_nl.any?{ |kw| equals_ignore_case(token.string, kw) }
            indent += 1
            index += insert_return_and_indent(tokens, index + 1, indent)
          end

          # キーワードの前でindentを１つ減らして改行、キーワードの後ろでindentを戻して改行。
          if @rule.kw_minus1_indent_nl_x_plus1_indent.any?{ |kw| equals_ignore_case(token.string, kw) }
            index += insert_return_and_indent(tokens, index    , indent - 1)
            index += insert_return_and_indent(tokens, index + 1, indent    )
          end

          # キーワードの前でindentを１つ減らして改行、キーワードの後ろでindentを戻して改行。
          if (equals_ignore_case(token.string, "VALUES"))
            indent -= 1
            index += insert_return_and_indent(tokens, index, indent)
          end

          # キーワードの前でindentを１つ減らして改行
          if (equals_ignore_case(token.string, "END"))
            indent -= 1
            index += insert_return_and_indent(tokens, index, indent)
          end

          # キーワードの前で改行
          if @rule.kw_nl_x.any?{ |kw| equals_ignore_case(token.string, kw) }
            index += insert_return_and_indent(tokens, index, indent)
          end

          # キーワードの前で改行, インデント+1
          if @rule.kw_nl_x_plus1_indent.any?{ |kw| equals_ignore_case(token.string, kw) }
            index += insert_return_and_indent(tokens, index, indent + 1)
          end

          # キーワードの前で改行。indentを強制的に０にする。
          if (equals_ignore_case(token.string, "UNION"    ) ||
              equals_ignore_case(token.string, "INTERSECT") ||
              equals_ignore_case(token.string, "EXCEPT"   )   )
            indent -= 2
            index += insert_return_and_indent(tokens, index    , indent)
            index += insert_return_and_indent(tokens, index + 1, indent)
          end

          if equals_ignore_case(token.string, "BETWEEN")
            encounter_between = true
          end

          if equals_ignore_case(token.string, "AND")
            # BETWEEN のあとのANDは改行しない。
            if not encounter_between
              index += insert_return_and_indent(tokens, index, indent)
            end
            encounter_between = false
          end

        elsif (token._type == AnbtSql::TokenConstants::COMMENT)

          if token.string.start_with?("/*")
            # マルチラインコメントの後に改行を入れる。
            index += insert_return_and_indent(tokens, index + 1, indent)
          elsif token.string.start_with?("--")
            index += insert_return_and_indent(tokens, index + 1, indent)
          end
        end
        prev = token

        index += 1
      end
    end


    #  before: [..., "(", space, "X", space, ")", ...]
    #  after:  [..., "(X)", ...]
    # ただし、これでは "(X)" という一つの symbol トークンになってしまう。
    # 整形だけが目的ならそれでも良いが、
    # せっかくなので symbol/X/symbol と分けたい。
    def special_treatment_for_parenthesis_with_one_element(tokens)
      (tokens.size - 1).downto(4).each{|index|
        next if (index >= tokens.size())

        t0 = ArrayUtil.get(tokens, index    )
        t1 = ArrayUtil.get(tokens, index - 1)
        t2 = ArrayUtil.get(tokens, index - 2)
        t3 = ArrayUtil.get(tokens, index - 3)
        t4 = ArrayUtil.get(tokens, index - 4)

        if (equals_ignore_case(t4.string      , "(") &&
            equals_ignore_case(t3.string.strip, "" ) &&
            equals_ignore_case(t1.string.strip, "" ) &&
            equals_ignore_case(t0.string      , ")")   )
          t4.string = t4.string + t2.string + t0.string
          ArrayUtil.remove(tokens, index    )
          ArrayUtil.remove(tokens, index - 1)
          ArrayUtil.remove(tokens, index - 2)
          ArrayUtil.remove(tokens, index - 3)
        end
      }
    end


    def format_list(tokens)
      return [] if tokens.empty?

      # SQLの前後に空白があったら削除する。
      # Delete space token at first and last of SQL tokens.

      token = ArrayUtil.get(tokens, 0)
      if (token._type == AnbtSql::TokenConstants::SPACE)
        ArrayUtil.remove(tokens, 0)
      end
      return [] if tokens.empty?

      token = ArrayUtil.get(tokens, tokens.size() - 1)
      if token._type == AnbtSql::TokenConstants::SPACE
        ArrayUtil.remove(tokens, tokens.size() - 1)
      end
      return [] if tokens.empty?

      modify_keyword_case(tokens)
      remove_symbol_side_space(tokens)
      concat_operator_for_oracle(tokens)

      format_list_main_loop(tokens)

      special_treatment_for_parenthesis_with_one_element(tokens)
      insert_space_between_tokens(tokens)

      return tokens
    end


    ##
    # index の箇所のトークンの前に挿入します。
    #
    # 空白を置き換えた場合:: return 0
    # 空白を挿入した場合:: return 1
    def insert_return_and_indent(tokens, index, indent, opt=nil)
      # 関数内では改行は挿入しない
      # No linefeed in function.
      return 0 if (@function_bracket.include?(true))

      begin
        # 挿入する文字列を作成する。
        s = "\n"

        # インデントをつける。
        indent = 0 if indent < 0 ## Java版と異なる
        s += @rule.indent_string * indent

        # 前後にすでにスペースがあれば、それを置き換える。
        token = ArrayUtil.get(tokens, index)
        if token._type == AnbtSql::TokenConstants::SPACE
          token.string = s
          return 0
        end

        token = ArrayUtil.get(tokens, index - 1)
        if token._type == AnbtSql::TokenConstants::SPACE
          token.string = s
          return 0
        end

        # 前後になければ、新たにスペースを追加する。
        ArrayUtil.add(tokens, index,
                   AnbtSql::Token.new(AnbtSql::TokenConstants::SPACE, s)
                   )
        return 1
      rescue IndexOutOfBoundsException => e
        if $DEBUG
          $stderr.puts e.message, e.backtrace
          $stderr.puts "tokens: "
          tokens.each_with_index{|t,i|
            $stderr.puts "index=%d: %s" % [i, t.inspect]
          }
          $stderr.puts "index/size: %d/%d / indent: %d / opt: %s" % [index, tokens.size, indent, opt]
        end
        return 0
      rescue => e
        raise e
      end
    end
  end
end
