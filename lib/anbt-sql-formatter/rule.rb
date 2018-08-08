# -*- coding: utf-8 -*-

require "anbt-sql-formatter/helper"

=begin
AnbtSqlFormatter: SQL整形ツール. SQL文を決められたルールに従い整形します。

フォーマットを実施するためには、入力されるSQLがSQL文として妥当であることが前提条件となります。

このクラスが準拠するSQL整形のルールについては、下記URLを参照ください。
http://homepage2.nifty.com/igat/igapyon/diary/2005/ig050613.html

このクラスは SQLの変換規則を表します。

@author WATANABE Yoshinori (a-san) : original version at 2005.07.04.
@author IGA Tosiki : marge into blanc Framework at 2005.07.04
@author sonota : porting to Ruby 2009-2010
=end

class AnbtSql
  class Rule

    include StringUtil

    attr_accessor :keyword, :indent_string, :function_names, :space_after_comma
    attr_accessor :kw_multi_words

    # nl: New Line
    # x: the keyword
    attr_accessor :kw_plus1_indent_x_nl
    attr_accessor :kw_minus1_indent_nl_x_plus1_indent
    attr_accessor :kw_nl_x
    attr_accessor :kw_nl_x_plus1_indent

    # Limit number of values per line in IN clause to this value.
    #
    # nil:: one value per line (default)
    # n (>=2):: n values per line
    # ONELINE_IN_VALUES_NUM:: all values in one line
    attr_accessor :in_values_num

    # キーワードの変換規則: 何もしない
    KEYWORD_NONE = 0

    # キーワードの変換規則: 大文字にする
    KEYWORD_UPPER_CASE = 1

    # キーワードの変換規則: 小文字にする
    KEYWORD_LOWER_CASE = 2

    # IN の値を一行表示する場合の in_values_num 値
    ONELINE_IN_VALUES_NUM = 0

    def initialize
      # キーワードの変換規則.
      @keyword = KEYWORD_UPPER_CASE

      # インデントの文字列. 設定は自由入力とする。
      # 通常は " ", " ", "\t" のいずれか。
      @indent_string = "    "

      @space_after_comma = false

      # __foo
      # ____KW
      @kw_plus1_indent_x_nl = %w(INSERT INTO CREATE DROP TRUNCATE TABLE CASE)

      # ____foo
      # __KW
      # ____bar
      @kw_minus1_indent_nl_x_plus1_indent = %w(FROM WHERE SET HAVING)
      @kw_minus1_indent_nl_x_plus1_indent.concat ["ORDER BY", "GROUP BY"]

      # __foo
      # ____KW
      @kw_nl_x_plus1_indent = %w(ON USING)

      # __foo
      # __KW
      @kw_nl_x = %w(OR THEN ELSE)
      # @kw_nl_x = %w(OR WHEN ELSE)

      @kw_multi_words = ["ORDER BY", "GROUP BY"]

      # 関数の名前。
      # Java版は初期値 null
      @function_names =
        [
         # getNumericFunctions
         "ABS", "ACOS", "ASIN", "ATAN", "ATAN2", "BIT_COUNT", "CEILING",
         "COS", "COT", "DEGREES", "EXP", "FLOOR", "LOG", "LOG10",
         "MAX", "MIN", "MOD", "PI", "POW", "POWER", "RADIANS", "RAND",
         "ROUND", "SIN", "SQRT", "TAN", "TRUNCATE",
         # getStringFunctions
         "ASCII", "BIN", "BIT_LENGTH", "CHAR", "CHARACTER_LENGTH",
         "CHAR_LENGTH", "CONCAT", "CONCAT_WS", "CONV", "ELT",
         "EXPORT_SET", "FIELD", "FIND_IN_SET", "HEX,INSERT", "INSTR",
         "LCASE", "LEFT", "LENGTH", "LOAD_FILE", "LOCATE", "LOCATE",
         "LOWER", "LPAD", "LTRIM", "MAKE_SET", "MATCH", "MID", "OCT",
         "OCTET_LENGTH", "ORD", "POSITION", "QUOTE", "REPEAT",
         "REPLACE", "REVERSE", "RIGHT", "RPAD", "RTRIM", "SOUNDEX",
         "SPACE", "STRCMP", "SUBSTRING", "SUBSTRING", "SUBSTRING",
         "SUBSTRING", "SUBSTRING_INDEX", "TRIM", "UCASE", "UPPER",
         # getSystemFunctions
         "DATABASE", "USER", "SYSTEM_USER", "SESSION_USER", "PASSWORD",
         "ENCRYPT", "LAST_INSERT_ID", "VERSION",
         # getTimeDateFunctions
         "DAYOFWEEK", "WEEKDAY", "DAYOFMONTH", "DAYOFYEAR", "MONTH",
         "DAYNAME", "MONTHNAME", "QUARTER", "WEEK", "YEAR", "HOUR",
         "MINUTE", "SECOND", "PERIOD_ADD", "PERIOD_DIFF", "TO_DAYS",
         "FROM_DAYS", "DATE_FORMAT", "TIME_FORMAT", "CURDATE",
         "CURRENT_DATE", "CURTIME", "CURRENT_TIME", "NOW", "SYSDATE",
         "CURRENT_TIMESTAMP", "UNIX_TIMESTAMP", "FROM_UNIXTIME",
         "SEC_TO_TIME", "TIME_TO_SEC"
        ]
    end


    def function?(name)
      if (@function_names == nil)
        return false
      end

      for i in 0...(@function_names.length)
        if (equals_ignore_case(@function_names[i], name))
          return true
        end
      end

      return false
    end
  end
end
