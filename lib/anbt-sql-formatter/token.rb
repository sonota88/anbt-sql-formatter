# -*- coding: utf-8 -*-

class AnbtSql
  class TokenConstants

    # 空文字. TAB,CR等も１つの文字列として含む。
    SPACE = :space

    # 記号. " <="のような２つで１つの記号もある。
    SYMBOL = :symbol

    # キーワード. "SELECT", "ORDER"など.
    KEYWORD = :keyword

    # 名前. テーブル名、列名など。
    # ダブルクォーテーションが付く場合がある。
    NAME = :name

    # 値. 数値（整数、実数）、文字列など。
    VALUE = :value

    # コメント. シングルラインコメントとマルチラインコメントがある。
    COMMENT = :comment

    # SQL文の終わり.
    END_OF_SQL = :end_of_sql

    # 解析不可能なトークン. 通常のSQLではありえない。
    UNKNOWN = :unknown
  end


  ##
  # [_type] type of token
  # [string] string of token
  # [pos] ソース文字列の先頭からのトークンの位置をあらわす。
  #       値は ゼロ(ZERO)オリジン。
  #       デフォルト値 -1 の場合には「位置情報に意味がない」ことをあらわす。
  #
  class AbstractToken
    attr_accessor :_type, :string, :pos

    @_type = nil

    @string = nil

    @pos = -1

    #
    # このバリューオブジェクトの文字列表現を取得する。
    # 
    # オブジェクトのシャロー範囲でしか to_s されない点に注意。
    # 
    # @return:: バリューオブジェクトの文字列表現。
    #
    def to_s
      @string
    end
  end


  class Token < AbstractToken
    def initialize(type, string, pos=nil)
      @_type = type
      @string = string

      @pos = pos || -1
    end
  end
end
