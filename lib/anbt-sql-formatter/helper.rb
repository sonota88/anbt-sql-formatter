class AnbtSql
  class Stack
    include Enumerable

    def initialize
      @arr = []
    end

    def each
      @arr.each{|item|
        yield item
      }
    end

    def clear
      @arr.clear
    end

    def push(o)
      @arr.push o
    end

    def pop
      @arr.pop
    end
  end
end


class String
  def endsWith(c)
    self[-1] == c ? true : false
  end

  def startsWith(c)
    self[0] == c ? true : false
  end

  def charAt(n)
    self[n..n]
  end

  def equals(str)
    self == str
  end

  def equalsIgnoreCase(other)
    self.upcase == other.upcase
  end

  def trim
    self.strip
  end
end


class Array
  def remove(n)
    self.delete_at n
  end

  def get(n)
    if n >= self.size || n <= -1
      raise IndexOutOfBoundsException
    end

    self[n]
  end

  def add(n,o)
    self.insert(n,o)
  end
end
