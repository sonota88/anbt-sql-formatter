# -*- coding: utf-8 -*-

require File.join(File.expand_path(File.dirname(__FILE__)), "helper")

require "anbt-sql-formatter/coarse-tokenizer"

class CoarseTokenizer
  attr_accessor :buf, :str, :result
end


def format(tokens)
  tokens.map{|t| t.to_s }.join("\n")
end


class TestCoarseTokenizer < Test::Unit::TestCase
  def setup
    @tok = CoarseTokenizer.new
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
  

  def test_tokenize
    msg = "tokenize - "

    assert_equals( msg, (<<EOB
<plain>aa</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
aa
EOB
                                                        ).chomp))
                 )
                 
    ########
    assert_equals( msg, (<<EOB
<plain>aa </>
<quote_double>"bb"</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
aa "bb"
EOB
                                                        ).chomp))
                 )

    ########
    assert_equals( msg, (<<EOB
<plain>aa </>
<quote_single>'bb'</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
aa 'bb'
EOB
                                                        ).chomp))
                 )

    ########
    assert_equals( msg, (<<EOB
<plain>aa </>
<comment_single>--bb<br></>
<plain>cc</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
aa --bb
cc
EOB
                                                        ).chomp))
                 )

    ########
    assert_equals( msg, (<<EOB
<plain>aa </>
<comment_multi>/* bb */</>
<plain> cc</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
aa /* bb */ cc
EOB
                                                        ).chomp))
                 )

    ########
    assert_equals( msg + "begin with multiline comment", (<<EOB
<comment_multi>/* bb */</>
<plain> cc</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
/* bb */ cc
EOB
                                       ).chomp))
                 )
  end


  def test_string_in_string
    msg = "string_in_string"

    ########
    assert_equals( msg, (<<EOB
<quote_double>"aa'bb'cc"</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
"aa'bb'cc"
EOB
                                                        ).chomp))
                 )

    ########
    assert_equals( msg, (<<EOB
<quote_single>'aa"bb"cc'</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
'aa"bb"cc'
EOB
                                                        ).chomp))
                 )
  end


  def test_comment_in_comment
    msg = "comment_in_comment - "
    ########
    assert_equals( msg, (<<EOB
<comment_single>--a--b</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
--a--b
EOB
                                                        ).chomp))
                 )

    ########
    assert_equals( msg, (<<EOB
<comment_single>-- aa /* bb */</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
-- aa /* bb */
EOB
                                                        ).chomp))
                 )

    ########
    assert_equals( msg, (<<EOB
<comment_multi>/* aa /* bb */</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
/* aa /* bb */
EOB
                                                        ).chomp))
                 )

    ########
    assert_equals( msg, (<<EOB
<comment_single>-- aa /* bb */</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
-- aa /* bb */
EOB
                                                        ).chomp))
                 )
  end


  def test_string_in_comment
    msg = "string_in_comment - "

    ########
    assert_equals( msg, (<<EOB
<comment_single>-- aa "bb" cc</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
-- aa "bb" cc
EOB
                                                        ).chomp))
                 )

    ########
    assert_equals( msg, (<<EOB
<comment_single>-- aa 'bb' cc</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
-- aa 'bb' cc
EOB
                                                        ).chomp))
                 )

    ########
    assert_equals( msg, (<<EOB
<comment_multi>/* aa "bb" cc */</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
/* aa "bb" cc */
EOB
                                                        ).chomp))
                 )

    ########
    assert_equals( msg, (<<EOB
<comment_multi>/* aa 'bb' cc */</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
/* aa 'bb' cc */
EOB
                                                        ).chomp))
                 )
  end
  

  def test_comment_in_string
    msg = "comment_in_string - "

    ########
    assert_equals( msg + "comment_single in quote_single", (<<EOB
<quote_single>'aa--bb'</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
'aa--bb'
EOB
                                                        ).chomp))
                 )

    ########
    assert_equals( msg + "comment_single in quote_double", (<<EOB
<quote_double>"aa--bb"</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
"aa--bb"
EOB
                                                        ).chomp))
                 )

    ########
    assert_equals( msg + "comment_multi in quote_double", (<<EOB
<quote_double>"aa /* bb */ cc"</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
"aa /* bb */ cc"
EOB
                                                        ).chomp))
                 )

    ########
    assert_equals( msg + "comment_multi in quote_double", (<<EOB
<quote_single>'aa /* bb */ cc'</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
'aa /* bb */ cc'
EOB
                                                        ).chomp))
                 )
  end
  

  def test_string_escape
    msg = "string_escape"

    ########
    assert_equals( msg, (<<EOB
<quote_double>"_a_\\\\_b_<br>_c_\\'_d_"</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
"_a_\\\\_b_\n_c_\\'_d_"
EOB
                                                        ).chomp))
                 )

    ########
    assert_equals( msg, (<<EOB
<quote_single>'_a_\\\\_b_<br>_c_\\'_d_'</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
'_a_\\\\_b_\n_c_\\'_d_'
EOB
                                                        ).chomp))
                 )

    ########
    assert_equals( msg, (<<EOB
<quote_double>"_a_""_b_"</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
"_a_""_b_"
EOB
                                                        ).chomp))
                 )

    ########
    assert_equals( msg, (<<EOB
<quote_single>'_a_''_b_'</>
EOB
                  ).chomp,
                 format(@tok.tokenize((<<EOB
'_a_''_b_'
EOB
                                                        ).chomp))
                 )
  end
end
