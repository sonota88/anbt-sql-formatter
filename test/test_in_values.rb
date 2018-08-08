# -*- coding: utf-8 -*-

require File.join(File.expand_path(File.dirname(__FILE__)), "helper")

require "anbt-sql-formatter/formatter"

class TestAnbtSqlInValues < Test::Unit::TestCase
  def test_format_without_in_values_num
    rule = base_rule
    @fmt = AnbtSql::Formatter.new(rule)
    msg = "without in_values_num setting"
    sql = "select * from users where id in (" + (1...30).to_a.join(",") + ")"
    expected = <<EOS
SELECT
    *
  FROM
    users
  WHERE
    id IN (
      1
      ,2
      ,3
      ,4
      ,5
      ,6
      ,7
      ,8
      ,9
      ,10
      ,11
      ,12
      ,13
      ,14
      ,15
      ,16
      ,17
      ,18
      ,19
      ,20
      ,21
      ,22
      ,23
      ,24
      ,25
      ,26
      ,27
      ,28
      ,29
    )
EOS

     assert_equals(msg, expected.strip, @fmt.format(sql))
  end

  def test_format_num_in_values
    rule = base_rule
    rule.in_values_num = 10
    @fmt = AnbtSql::Formatter.new(rule)
    msg = "num in values"
    sql = "select * from users where id in (" + (1...100).to_a.join(",") + ")"
    expected = <<EOS
SELECT
    *
  FROM
    users
  WHERE
    id IN (
      1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,10
      ,11 ,12 ,13 ,14 ,15 ,16 ,17 ,18 ,19 ,20
      ,21 ,22 ,23 ,24 ,25 ,26 ,27 ,28 ,29 ,30
      ,31 ,32 ,33 ,34 ,35 ,36 ,37 ,38 ,39 ,40
      ,41 ,42 ,43 ,44 ,45 ,46 ,47 ,48 ,49 ,50
      ,51 ,52 ,53 ,54 ,55 ,56 ,57 ,58 ,59 ,60
      ,61 ,62 ,63 ,64 ,65 ,66 ,67 ,68 ,69 ,70
      ,71 ,72 ,73 ,74 ,75 ,76 ,77 ,78 ,79 ,80
      ,81 ,82 ,83 ,84 ,85 ,86 ,87 ,88 ,89 ,90
      ,91 ,92 ,93 ,94 ,95 ,96 ,97 ,98 ,99
    )
EOS

     assert_equals(msg, expected.strip, @fmt.format(sql))
  end

  def test_format_str_in_values
    rule = base_rule
    rule.in_values_num = 10
    @fmt = AnbtSql::Formatter.new(rule)
    msg = "str in values"
    sql = "select * from users where id in (" + (1...100).map { |i| "'#{i}'"  }.join(",") + ")"
    expected = <<EOS
SELECT
    *
  FROM
    users
  WHERE
    id IN (
      '1' ,'2' ,'3' ,'4' ,'5' ,'6' ,'7' ,'8' ,'9' ,'10'
      ,'11' ,'12' ,'13' ,'14' ,'15' ,'16' ,'17' ,'18' ,'19' ,'20'
      ,'21' ,'22' ,'23' ,'24' ,'25' ,'26' ,'27' ,'28' ,'29' ,'30'
      ,'31' ,'32' ,'33' ,'34' ,'35' ,'36' ,'37' ,'38' ,'39' ,'40'
      ,'41' ,'42' ,'43' ,'44' ,'45' ,'46' ,'47' ,'48' ,'49' ,'50'
      ,'51' ,'52' ,'53' ,'54' ,'55' ,'56' ,'57' ,'58' ,'59' ,'60'
      ,'61' ,'62' ,'63' ,'64' ,'65' ,'66' ,'67' ,'68' ,'69' ,'70'
      ,'71' ,'72' ,'73' ,'74' ,'75' ,'76' ,'77' ,'78' ,'79' ,'80'
      ,'81' ,'82' ,'83' ,'84' ,'85' ,'86' ,'87' ,'88' ,'89' ,'90'
      ,'91' ,'92' ,'93' ,'94' ,'95' ,'96' ,'97' ,'98' ,'99'
    )
EOS

     assert_equals(msg, expected.strip, @fmt.format(sql))
  end

  def test_format_oneline_in_values
    rule = base_rule
    rule.in_values_num = AnbtSql::Rule::ONELINE_IN_VALUES_NUM
    @fmt = AnbtSql::Formatter.new(rule)
    msg = "oneline in values"
    sql = "select * from users where id in (" + (1...50).to_a.join(",") + ")"
    expected = <<EOS
SELECT
    *
  FROM
    users
  WHERE
    id IN (
      1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,10 ,11 ,12 ,13 ,14 ,15 ,16 ,17 ,18 ,19 ,20 ,21 ,22 ,23 ,24 ,25 ,26 ,27 ,28 ,29 ,30 ,31 ,32 ,33 ,34 ,35 ,36 ,37 ,38 ,39 ,40 ,41 ,42 ,43 ,44 ,45 ,46 ,47 ,48 ,49
    )
EOS

     assert_equals(msg, expected.strip, @fmt.format(sql))
  end

  def test_format_with_space_after_comma
    rule = base_rule
    rule.in_values_num = 10
    rule.space_after_comma = true
    @fmt = AnbtSql::Formatter.new(rule)
    msg = "num in values"
    sql = "select * from users where id in (" + (1...100).to_a.join(",") + ")"
    expected = <<EOS
SELECT
    *
  FROM
    users
  WHERE
    id IN (
      1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10
      , 11 , 12 , 13 , 14 , 15 , 16 , 17 , 18 , 19 , 20
      , 21 , 22 , 23 , 24 , 25 , 26 , 27 , 28 , 29 , 30
      , 31 , 32 , 33 , 34 , 35 , 36 , 37 , 38 , 39 , 40
      , 41 , 42 , 43 , 44 , 45 , 46 , 47 , 48 , 49 , 50
      , 51 , 52 , 53 , 54 , 55 , 56 , 57 , 58 , 59 , 60
      , 61 , 62 , 63 , 64 , 65 , 66 , 67 , 68 , 69 , 70
      , 71 , 72 , 73 , 74 , 75 , 76 , 77 , 78 , 79 , 80
      , 81 , 82 , 83 , 84 , 85 , 86 , 87 , 88 , 89 , 90
      , 91 , 92 , 93 , 94 , 95 , 96 , 97 , 98 , 99
    )
EOS

     assert_equals(msg, expected.strip, @fmt.format(sql))
  end

  def test_format_ignore_in_values_compact_when_select
    rule = base_rule
    rule.in_values_num = AnbtSql::Rule::ONELINE_IN_VALUES_NUM
    @fmt = AnbtSql::Formatter.new(rule)
    msg = "num in values"
    sql = "select * from users where id in (select user_id from admins)"
    expected = <<EOS
SELECT
    *
  FROM
    users
  WHERE
    id IN (
      SELECT
          user_id
        FROM
          admins
    )
EOS

     assert_equals(msg, expected.strip, @fmt.format(sql))
  end

  private

  def base_rule
    rule = AnbtSql::Rule.new
    rule.indent_string = "  "
    rule
  end
end
