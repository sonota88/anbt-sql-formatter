# -*- coding: utf-8 -*-

require File.join(File.expand_path(File.dirname(__FILE__)), "helper")

require "anbt-sql-formatter/coarse-tokenizer"

class CoarseTokenizer
  attr_accessor :buf, :str, :result
end



class TestCoarseTokenizer < Test::Unit::TestCase
  def setup
    @tok = CoarseTokenizer.new
  end

  def _format(tokens)
    tokens.map{|t|
      "#{t._type} (#{t.string})"
    }.join("\n")
  end

  
  def test_shift_to_buf
    @tok.buf = ""
    @tok.str = "abcdefg"

    msg = "shift_to_buf - "
    @tok.shift_to_buf(1)
    assert_equals( msg,  "a", @tok.buf )
    assert_equals( msg,  "bcdefg", @tok.str )

    @tok.shift_to_buf(2)
    assert_equals( msg,  "abc", @tok.buf )
    assert_equals( msg,  "defg", @tok.str )
  end


  def test_shift_token
    @tok.result = []
    @tok.buf = "ABC"
    @tok.str = "'def'"

    msg = "shift_token - "
    @tok.shift_token(1, :plain, :comment, :start)
    assert_equals( msg,  :plain, @tok.result.last._type)
    assert_equals( msg,  "ABC", @tok.result.last.string)
    assert_equals( msg,  "'", @tok.buf)
    assert_equals( msg,  "def'", @tok.str)

    @tok.result = []
    @tok.buf = "'ABC"
    @tok.str = "'def"
    
    @tok.shift_token(1, :comment, :plain, :end)
    assert_equals( msg,  :comment, @tok.result.last._type)
    assert_equals( msg,  "'ABC'", @tok.result.last.string)
    assert_equals( msg,  "", @tok.buf)
    assert_equals( msg,  "def", @tok.str)
  end
  

  def test_tokenize_1
    assert_equals(
      "tokenize 1",
      strip_indent(
        <<-EOB
        plain (aa)
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        aa
        EOB
      )))
    )
  end

  def test_tokenize_2
    assert_equals(
      "tokenize 2",
      strip_indent(
        <<-EOB
        plain (aa )
        quote_double ("bb")
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        aa "bb"
        EOB
      )))
    )
  end

  def test_tokenize_3
    assert_equals(
      "tokenize 3",
      strip_indent(
        <<-EOB
        plain (aa )
        quote_single ('bb')
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        aa 'bb'
        EOB
      )))
    )
  end

  def test_tokenize_4
    assert_equals(
      "tokenize 4",
      strip_indent(
        <<-EOB
        plain (aa )
        comment_single (--bb\n)
        plain (cc)
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        aa --bb
        cc
        EOB
      )))
    )
  end

  def test_tokenize_5
    assert_equals(
      "tokenize 5",
      strip_indent(
        <<-EOB
        plain (aa )
        comment_multi (/* bb */)
        plain ( cc)
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        aa /* bb */ cc
        EOB
      )))
    )
  end

  def test_tokenize_6
    assert_equals(
      "tokenize - begin with multiline comment",
      strip_indent(
        <<-EOB
        comment_multi (/* bb */)
        plain ( cc)
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        /* bb */ cc
        EOB
      )))
    )
  end


  def test_string_in_string_1
    assert_equals(
      "string_in_string 1",
      strip_indent(
        <<-EOB
        quote_double ("aa'bb'cc")
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        "aa'bb'cc"
        EOB
      )))
    )
  end

  def test_string_in_string_2
    assert_equals(
      "string_in_string 2",
      strip_indent(
        <<-EOB
        quote_single ('aa"bb"cc')
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        'aa"bb"cc'
        EOB
      )))
    )
  end


  def test_comment_in_comment_1
    assert_equals(
      "comment_in_comment 1",
      strip_indent(
        <<-EOB
        comment_single (--a--b)
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        --a--b
        EOB
      )))
    )
  end

  def test_comment_in_comment_2
    assert_equals(
      "comment_in_comment 2",
      strip_indent(
        <<-EOB
        comment_single (-- aa /* bb */)
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        -- aa /* bb */
        EOB
      )))
    )
  end

  def test_comment_in_comment_3
    assert_equals(
      "comment_in_comment 3",
      strip_indent(
        <<-EOB
        comment_multi (/* aa /* bb */)
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        /* aa /* bb */
        EOB
      )))
    )
  end

  def test_comment_in_comment_4
    assert_equals(
      "comment_in_comment 4",
      strip_indent(
        <<-EOB
        comment_multi (/* aa -- bb */)
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        /* aa -- bb */
        EOB
      )))
    )
  end


  def test_string_in_comment_1
    assert_equals(
      "string_in_comment 1",
      strip_indent(
        <<-EOB
        comment_single (-- aa "bb" cc)
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        -- aa "bb" cc
        EOB
      )))
    )
  end

  def test_string_in_comment_2
    assert_equals(
      "string_in_comment 2",
      strip_indent(
        <<-EOB
        comment_single (-- aa 'bb' cc)
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        -- aa 'bb' cc
        EOB
      )))
    )
  end

  def test_string_in_comment_3
    assert_equals(
      "string_in_comment 3",
      strip_indent(
        <<-EOB
        comment_multi (/* aa "bb" cc */)
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        /* aa "bb" cc */
        EOB
      )))
    )
  end

  def test_string_in_comment_4
    assert_equals(
      "string_in_comment 4",
      strip_indent(
        <<-EOB
        comment_multi (/* aa 'bb' cc */)
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        /* aa 'bb' cc */
        EOB
      )))
    )
  end
  

  def test_comment_in_string_1
    assert_equals(
      "comment_in_string - comment_single in quote_single",
      strip_indent(
        <<-EOB
        quote_single ('aa--bb')
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        'aa--bb'
        EOB
      )))
    )
  end

  def test_comment_in_string_2
    assert_equals(
      "comment_in_string - comment_single in quote_double",
      strip_indent(
        <<-EOB
        quote_double ("aa--bb")
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        "aa--bb"
        EOB
      )))
    )
  end

  def test_comment_in_string_3
    assert_equals(
      "comment_in_string - comment_multi in quote_double",
      strip_indent(
        <<-EOB
        quote_double ("aa /* bb */ cc")
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        "aa /* bb */ cc"
        EOB
      )))
    )
  end

  def test_comment_in_string_4
    assert_equals(
      "comment_in_string - comment_multi in quote_double",
      strip_indent(
        <<-EOB
        quote_single ('aa /* bb */ cc')
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        'aa /* bb */ cc'
        EOB
      )))
    )
  end
  

  def test_string_escape_1
    assert_equals(
      "string_escape 1",
      strip_indent(
        <<-EOB
        quote_double ("_a_\\\\_b_\n_c_\\'_d_")
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        "_a_\\\\_b_\n_c_\\'_d_"
        EOB
      )))
    )
  end

  def test_string_escape_2
    assert_equals(
      "string_escape 2",
      strip_indent(
        <<-EOB
        quote_single ('_a_\\\\_b_\n_c_\\'_d_')
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        '_a_\\\\_b_\n_c_\\'_d_'
        EOB
      )))
    )
  end

  def test_string_escape_3
    assert_equals(
      "string_escape 3",
      strip_indent(
        <<-EOB
        quote_double ("_a_""_b_")
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        "_a_""_b_"
        EOB
      )))
    )
  end

  def test_string_escape_4
    assert_equals(
      "string_escape 4",
      strip_indent(
        <<-EOB
        quote_single ('_a_''_b_')
        EOB
      ),
      _format(@tok.tokenize(strip_indent(
        <<-EOB
        '_a_''_b_'
        EOB
      )))
    )
  end
end
