# -*- coding: utf-8 -*-

=begin
エスケープ文字
=end

class CoarseToken
  attr_accessor :_type, :string

  def initialize(type, str)
    @_type = type
    @string = str
  end

  def to_s
    @string
  end
end


class CoarseTokenizer
  def initialize
    @comment_single_start = /--/
    @comment_multi_start  = /\/\*/
    @comment_multi_end    = /\*\//
  end

=begin rdoc
These are exclusive:
* double quote string
* single quote string
* single line comment
* multiple line comment

ソース先頭から見ていって先に現れたものが優先される。

@result <= @buf <= @str
=end

  def tokenize(str)
    @str = str
    @str.gsub!("\r\n", "\n")
    out_of_quote_single   = true
    out_of_quote_double   = true
    out_of_comment_single = true
    out_of_comment_multi  = true

    @result = []
    @buf = ""
    @mode = :plain

    while @str.size > 0

      if /\A(")/ =~ str && out_of_quote_double &&
          out_of_quote_single && out_of_comment_single && out_of_comment_multi
        ## begin double quote

        length = $1.size
        shift_token(length, :plain, :quote_double, :start)
        out_of_quote_double = false
        
      elsif /\A(")/ =~ str && !(out_of_quote_double) &&
          out_of_quote_single && out_of_comment_single && out_of_comment_multi
        ## end double quote
         
        length = $1.size
        if /\A(".")/ =~ str ## schema.table
          shift_to_buf(3)
        elsif /\A("")/ =~ str ## escaped double quote
          shift_to_buf(2)
        else
          shift_token(length, :quote_double, :plain, :end)
          out_of_quote_double = true
        end

      elsif /\A(')/ =~ str && out_of_quote_single &&
          out_of_quote_double && out_of_comment_single && out_of_comment_multi
        ## begin single quote
        
        length = $1.size
        shift_token(length, :plain, :quote_single, :start)
        out_of_quote_single = false
      elsif /\A(')/ =~ str && !(out_of_quote_single) &&
          out_of_quote_double && out_of_comment_single && out_of_comment_multi
        ## end single quote

        length = $1.size
        if /\A('')/ =~ @str ## escaped single quote
          shift_to_buf(2)
        else
        shift_token(length, :quote_single, :plain, :end)
          out_of_quote_single = true
        end
        
      elsif /\A(#{@comment_single_start})/ =~ str && out_of_comment_single &&
         out_of_quote_single && out_of_quote_double && out_of_comment_multi
        ## begin single line comment
        
        length = $1.size
        shift_token(length, :plain, :comment_single, :start)
        out_of_comment_single = false

      elsif /\A(\n)/ =~ str && !(out_of_comment_single) &&
          out_of_quote_single && out_of_quote_double && out_of_comment_multi
        ## end single line comment
       
        length = $1.size
        shift_token(length, :comment_single, :plain, :end)
        out_of_comment_single = true

      elsif /\A(#{@comment_multi_start})/ =~ str &&
          out_of_quote_single && out_of_quote_double && out_of_comment_single && out_of_comment_multi
        ## begin multi line comment
        
        length = $1.size
        shift_token(length, :plain, :comment_multi, :start)
        out_of_comment_multi = false

      elsif /\A(#{@comment_multi_end})/ =~ str &&
          out_of_quote_single && out_of_quote_double && out_of_comment_single && !(out_of_comment_multi)
        ## end multi line comment
        
        length = $1.size
        shift_token(length, :comment_multi, :plain, :end)
        out_of_comment_multi = true

      elsif /\A\\/ =~ str
        ## escape char
        shift_to_buf(2)

      else
        shift_to_buf(1)
        
      end
    end
    @result << CoarseToken.new(@mode, @buf+@str) if (@buf+@str).size > 0

    @result
  end


  def shift_to_buf(n)
    @buf << @str[0...n]
    @str[0...n] = ""
  end
  
  
  def shift_token(length, type, mode, flag)
    case flag
    when :start
      @result << CoarseToken.new(type, @buf) if @buf.size > 0
      @buf = @str[0..(length-1)] # <length> char from head
    when :end
      @result << CoarseToken.new(type, @buf+@str[0..(length-1)]) if @buf.size > 0
      @buf = ""
    else
      raise "must not happen"
    end

    @str[0..(length-1)] = ""
    @mode = mode
  end
end


if $0 == __FILE__
  tok = CoarseTokenizer.new
  src =  File.read(ARGV[0])
  coarse_tokens  = tok.tokenize(src)

  coarse_tokens.each{|t|
    puts t.to_s
  }
end
