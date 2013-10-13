# -*- coding: utf-8 -*-

=begin rdoc
BlancoSqlFormatterException : SQL整形ツールの例外を表します。

@author IGA Tosiki : 新規作成 at 2005.08.03
=end

=begin rdoc
* Rubyの流儀に合わせて "xxxError" とした方が良いかもしれない。

@author sonota (2009-11-xx)
=end


class AnbtSql
  class FormatterException < IOError
    def initialize(msg=nil)
      super(msg)
    end
  end
end

class IndexOutOfBoundsException < StandardError
  def initialize(msg=nil)
    super(msg)
  end
end
