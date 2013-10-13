require "test/unit"
require "pp"

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "lib")

class Helper
  def Helper.format_tokens(list)
    list.map{|token|
      "#{token._type} (#{token.string})"
    }.join("\n")
  end
end


def assert_equals(a,b,c)
  assert_equal(b,c,a)
end

def strip_indent(text)
  text.split("\n").map{|line|
    line.sub(/^ */, "")
  }.join("\n")
end
