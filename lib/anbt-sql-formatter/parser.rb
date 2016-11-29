# -*- coding: utf-8 -*-

require "pp"

require "anbt-sql-formatter/token"
require "anbt-sql-formatter/constants"
require "anbt-sql-formatter/helper"
require "anbt-sql-formatter/coarse-tokenizer"

class AnbtSql
  class Parser

    include ::AnbtSql::StringUtil

    def initialize(rule)
      @rule = rule

      # 解析前の文字列
      @before = nil

      # 解析中の位置
      @pos = nil

      # 解析中の文字。
      @char = nil

      @token_pos = nil

      # ２文字からなる記号。
      # なお、|| は文字列結合にあたります。
      @two_character_symbol = [ "<>", "<=", ">=", "||", "!=" ]
    end


    ##
    # 2005.07.26:: Tosiki Iga \r も処理範囲に含める必要があります。
    # 2005.08.12:: Tosiki Iga 65535(もとは-1)はホワイトスペースとして扱うよう変更します。
    def space?(c)
      return c == ' ' ||
        c == "\t" ||
        c == "\n" ||
        c == "\r" ||
        c == 65535
    end


    ##
    # 文字として認識して妥当かどうかを判定します。
    # 全角文字なども文字として認識を許容するものと判断します。
    def letter?(c)
      return false if space?(c)
      return false if digit?(c)
      return false if symbol?(c)

      true
    end


    def digit?(c)
      return "0" <= c && c <= '9'
    end


    ##
    # "#" は文字列の一部とします
    # アンダースコアは記号とは扱いません
    # これ以降の文字の扱いは保留
    def symbol?(c)
      %w(" ? % & ' \( \) | * + , - . / : ; < = > !).include? c
      #"
    end


    ##
    # トークンを次に進めます。
    # 1. posを進める。
    # 2. sに結果を返す。
    # 3. typeにその種類を設定する。
    # 不正なSQLの場合、例外が発生します。
    # ここでは、文法チェックは行っていない点に注目してください。
    def next_sql_token
      $stderr.puts "next_token #{@pos} <#{@before}> #{@before.length}" if $DEBUG

      start_pos = @pos

      if @pos >= @before.length
        @pos += 1
        return nil
      end

      @char = char_at(@before, @pos)

      if space?(@char)
        work_string = ""
        loop {
          work_string += @char

          is_next_char_space = false
          if @pos + 1 < @before.size &&
            space?(char_at(@before, @pos+1))
              is_next_char_space = true
          end

          if not is_next_char_space
            @pos += 1
            return AnbtSql::Token.new(AnbtSql::TokenConstants::SPACE,
                                      work_string, start_pos)
          else
            @pos += 1
            next
          end
        }


      elsif @char == ";"
        @pos += 1
        # 2005.07.26 Tosiki Iga セミコロンは終了扱いではないようにする。
        return AnbtSql::Token.new(AnbtSql::TokenConstants::SYMBOL,
                                    ";", start_pos)

      elsif digit?(@char)
        if /^(0x[0-9a-fA-F]+)/       =~ @before[@pos..-1] || # hex
           /^(\d+(\.\d+(e-?\d+)?)?)/ =~ @before[@pos..-1]    # integer, float or scientific
          num = $1
          @pos += num.length
          return AnbtSql::Token.new(AnbtSql::TokenConstants::VALUE,
                                    num, start_pos)
        else
          raise "must not happen"
        end

      elsif letter?(@char)
        s = ""
        # 文字列中のドットについては、文字列と一体として考える。
        while (letter?(@char) || digit?(@char) || @char == '.')
          s += @char
          @pos += 1
          if (@pos >= @before.length())
            break
          end

          @char = char_at(@before, @pos)
        end

        if AnbtSql::Constants::SQL_RESERVED_WORDS.map{|w| w.upcase }.include?(s.upcase)
          return AnbtSql::Token.new(AnbtSql::TokenConstants::KEYWORD,
                                      s, start_pos)
        end

        return AnbtSql::Token.new(AnbtSql::TokenConstants::NAME,
                                    s, start_pos)

      elsif symbol?(@char)
        s = "" + @char
        @pos += 1
        if (@pos >= @before.length())
          return AnbtSql::Token.new(AnbtSql::TokenConstants::SYMBOL,
                                    s, start_pos)
        end

        # ２文字の記号かどうか調べる
        ch2 = char_at(@before, @pos)
        #for (int i = 0; i < two_character_symbol.length; i++) {
        for i in 0...@two_character_symbol.length
          if (char_at(@two_character_symbol[i], 0) == @char &&
              char_at(@two_character_symbol[i], 1) == ch2)
            @pos += 1
            s += ch2
            break
          end
        end

        if @char == "-" &&
          /^(\d+(\.\d+(e-?\d+)?)?)/ =~ @before[@pos..-1] # float or scientific
          num = $1
          @pos += num.length
          return AnbtSql::Token.new(AnbtSql::TokenConstants::VALUE,
                                    s + num, start_pos)
        end

        return AnbtSql::Token.new(AnbtSql::TokenConstants::SYMBOL,
                                    s, start_pos)


      else
        @pos += 1
        return AnbtSql::Token.new( AnbtSql::TokenConstants::UNKNOWN,
                                     "" + @char,
                                     start_pos )
      end
    end


    def prepare_tokens(coarse_tokens)
      @tokens = []

      pos = 0
      while pos < coarse_tokens.size
        coarse_token = coarse_tokens[pos]

        case coarse_token._type

        when :quote_single
          @tokens << AnbtSql::Token.new(AnbtSql::TokenConstants::VALUE,
                                          coarse_token.string)
        when :quote_double
          @tokens << AnbtSql::Token.new(AnbtSql::TokenConstants::NAME,
                                          coarse_token.string)
        when :comment_single
          @tokens << AnbtSql::Token.new(AnbtSql::TokenConstants::COMMENT,
                                          coarse_token.string.chomp)
        when :comment_multi
          @tokens << AnbtSql::Token.new(AnbtSql::TokenConstants::COMMENT,
                                          coarse_token.string)
        when :plain
          @before = coarse_token.string
          @pos = 0
          count = 0
          loop {
            token = next_sql_token()
            if $DEBUG
              pp "@" * 64, count, token, token.class
            end

            # if token._type == AnbtSql::TokenConstants::END_OF_SQL
            if token == nil
              break
            end

            @tokens.push token
            count += 1
          }
        end

        pos += 1
      end

      @tokens << AnbtSql::Token.new(AnbtSql::TokenConstants::END_OF_SQL,
                                      "")
    end


    ##
    # ２つ以上並んだキーワードは１つのキーワードとみなします。
    #     ["a", " ", "group", " ", "by", " ", "b"]
    #  => ["a", " ", "group by",         " ", "b"]
    def concat_multiwords_keyword(tokens)
      temp_kw_list = @rule.kw_multi_words.map{|kw| kw.split(" ") }

      # ワード数が多い順から
      temp_kw_list.sort{ |a, b|
        b.size <=> a.size
      }.each{|kw|
        index = 0
        target_tokens_size = kw.size * 2 - 1

        while index <= tokens.size - target_tokens_size
          temp_tokens = tokens[index, target_tokens_size].map {|x|
            x.string.sub(/\s+/, " ")
          }

          if equals_ignore_case(kw.join(" "), temp_tokens.join)
            tokens[index].string = temp_tokens.join
            (target_tokens_size-1).downto(1).each{|c|
              tokens.delete_at(index + c)
            }
          end

          index += 1
        end
      }
    end


    def next_token
      @tokens[@token_pos]
    end


    ##
    # SQL文字列をトークンの配列に変換し返します。
    #
    # sql_str:: 変換前のSQL文
    def parse(sql_str)
      coarse_tokens = CoarseTokenizer.new.tokenize(sql_str)

      prepare_tokens(coarse_tokens)

      tokens = []
      count = 0
      @token_pos = 0
      loop {
        token = next_token()

        if $DEBUG
          pp "=" * 64, count, token, token.class
        end

        if token._type == AnbtSql::TokenConstants::END_OF_SQL
          break
        else
          ;
        end

        tokens.push token
        count += 1
        @token_pos += 1
      }

      concat_multiwords_keyword(tokens)

      tokens
    end
  end
end
