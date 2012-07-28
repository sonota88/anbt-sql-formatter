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
    assert_equals( msg + "space",
                 (<<EOB
<space> </>
EOB
                  ).chomp,
                 Helper.format_tokens([ @parser.next_sql_token ])
                 )

    ########
    @parser.before = "a b"
    @parser.pos = 1
    assert_equals( msg + "space",
                 (<<EOB
<space> </>
EOB
                  ).chomp,
                 Helper.format_tokens([ @parser.next_sql_token ])
                 )

    ########
    @parser.before = ","
    @parser.pos = 0
    assert_equals( msg + "symbol",
                 (<<EOB
<symbol>,</>
EOB
                  ).chomp,
                 Helper.format_tokens([ @parser.next_sql_token ])
                 )

    ########
    @parser.before = "select"
    @parser.pos = 0
    assert_equals( msg + "keyword: select",
                 (<<EOB
<keyword>select</>
EOB
                  ).chomp,
                 Helper.format_tokens([ @parser.next_sql_token ])
                 )

    ########
    @parser.before = "case"
    @parser.pos = 0
    assert_equals( msg + "keyword: case", 
                 (<<EOB
<keyword>case</>
EOB
                  ).chomp,
                 Helper.format_tokens([ @parser.next_sql_token ])
                 )

    ########
    @parser.before = "xxx123"
    @parser.pos = 0
    assert_equals( msg + "name", 
                 (<<EOB
<name>xxx123</>
EOB
                  ).chomp,
                 Helper.format_tokens([ @parser.next_sql_token ])
                 )

    ########
    @parser.before = '123'
    @parser.pos = 0
    assert_equals( msg + "value", 
                 (<<EOB
<value>123</>
EOB
                  ).chomp,
                 Helper.format_tokens([ @parser.next_sql_token ])
                 )

    ########
    @parser.before = '1.23'
    @parser.pos = 0
    assert_equals( msg + "value", 
                 (<<EOB
<value>1.23</>
EOB
                  ).chomp,
                 Helper.format_tokens([ @parser.next_sql_token ])
                 )

    ########
    @parser.before = '-1.23 '
    @parser.pos = 0
    assert_equals( msg + "value", 
                 (<<EOB
<value>-1.23</>
EOB
                  ).chomp,
                 Helper.format_tokens([ @parser.next_sql_token ])
                 )

    ########
    @parser.before = '1.23e45 '
    @parser.pos = 0
    assert_equals( msg + "value", 
                 (<<EOB
<value>1.23e45</>
EOB
                  ).chomp,
                 Helper.format_tokens([ @parser.next_sql_token ])
                 )

    ########
    @parser.before = '1.23e-45 '
    @parser.pos = 0
    assert_equals( msg + "value", 
                 (<<EOB
<value>1.23e-45</>
EOB
                  ).chomp,
                 Helper.format_tokens([ @parser.next_sql_token ])
                 )

    ########
    @parser.before = '-1.23e-45 '
    @parser.pos = 0
    assert_equals( msg + "value", 
                 (<<EOB
<value>-1.23e-45</>
EOB
                  ).chomp,
                 Helper.format_tokens([ @parser.next_sql_token ])
                 )

    ########
    @parser.before = '0x01 '
    @parser.pos = 0
    assert_equals( msg + "value", 
                 (<<EOB
<value>0x01</>
EOB
                  ).chomp,
                 Helper.format_tokens([ @parser.next_sql_token ])
                 )

    ########
    @parser.before = '1x'
    @parser.pos = 0
    assert_equals( msg + "value", 
                 (<<EOB
<value>1</>
EOB
                  ).chomp,
                 Helper.format_tokens([ @parser.next_sql_token ])
                 )
  end


  def test_parser
    msg = "parser basic case - "

    ########
    assert_equals( msg + "", (<<EOB
<keyword>select</>
<space> </>
<name>a</>
<space> </>
<keyword>from</>
<space> </>
<name>b</>
<symbol>;</>
EOB
                   ).strip, Helper.format_tokens( @parser.parse( (<<EOB
select a from b;
EOB
                                                                  ).chop
                                                                 ))
                   )

    ########
    assert_equals( msg + "minus + non-number", (<<EOB
<symbol>-</>
<name>a</>
EOB
                   ).strip, Helper.format_tokens( @parser.parse( (<<EOB
-a
EOB
                                                                  ).chop
                                                                 ))
                   )

    ########
    assert_equals( msg + "single comment", (<<EOB
<keyword>select</>
<space>\n</>
<comment>-- x</>
<name>a</>
<space>\n</>
EOB
                   ).strip, Helper.format_tokens( @parser.parse(<<EOB
select
-- x
a
EOB
                                                                ))
                   )

    ########
    assert_equals( msg + "parenthesis in single quote", (<<EOB
<value>'()'</>
EOB
                   ).strip, Helper.format_tokens( @parser.parse((<<EOB
'()'
EOB
                                                                 ).strip
                                                                ))
                   )

    ########
    assert_equals( msg + "parenthesis in double quote", (<<EOB
<name>"()"</>
EOB
                   ).strip, Helper.format_tokens( @parser.parse((<<EOB
"()"
EOB
                                                                 ).strip
                                                                ))
                   )

    ########
    assert_equals( msg + "multiple line comment: 1", (<<EOB
<name>aa</>
<comment>/*bb*/</>
<name>cc</>
EOB
                   ).strip, Helper.format_tokens( @parser.parse((<<EOB
aa/*bb*/cc
EOB
                                                                 ).strip
                                                                ))
                   )

    ########
    assert_equals( msg + "multiple line comment: 2", (<<EOB
<name>aa</>
<comment>/*b
b*/</>
<name>cc</>
EOB
                   ).strip, Helper.format_tokens( @parser.parse((<<EOB
aa/*b
b*/cc
EOB
                                                                 ).strip
                                                                ))
                   )

    ########
    assert_equals( msg + "invalid paired double quote", (<<EOB
<name>aa</>
<name>"bb</>
EOB
                   ).strip, Helper.format_tokens( @parser.parse((<<EOB
aa"bb
EOB
                                                                 ).strip
                                                                ))
                   )

    ########
    assert_equals( msg + "multiwords keyword", (<<EOB
<keyword>group by</>
EOB
                   ).strip, Helper.format_tokens( @parser.parse((<<EOB
group by
EOB
                                                                 ).strip
                                                                ))
                   )

    ########
    assert_equals( msg + "multiwords keyword 2",
                   (<<EOB
<name>a</>
<space> </>
<keyword>group by</>
<space> </>
<name>B</>
EOB
                    ).strip,
                   Helper.format_tokens( @parser.parse("a group by B") )
                   )

  end
end
