# 指称语义

# 简单说，就是把一个 AST 转换成一个 Ruby 代码的字符串

# 若转成 Ruby 代码字符串，就可以用 Ruby 的 eval 方法去执行该字符串，也就间接的得到了 AST 所表达语言的计算结果

# 但计算结果并不是指称语义的重点，重点是转换过程
# 了解该过程后，也可以将 AST 转为 JavaScript 代码的字符串，然后用 JS 的 eval 方法去执行
# 同理，也可以将 AST 转为 任意一种代码，交给对应环境去执行


# 表达式

class Number < Struct.new(:value)
  def to_s
    value.to_s
  end

  def inspect
    "^#{self}^"
  end

  def to_ruby
    "-> e { #{value.inspect} }"
  end
end

class Boolean < Struct.new(:value)
  def to_s
    value.to_s
  end

  def inspect
    "^#{self}^"
  end

  def to_ruby
    "-> e { #{value.inspect} }"
  end
end

class Variable < Struct.new(:name)
  def to_s
    name.to_s
  end

  def inspect
    "^#{self}^"
  end

  def to_ruby
    "-> e { e[#{name.inspect}] }"
  end
end

class Add < Struct.new(:left, :right)
  def to_s
    "#{left} + #{right}"
  end

  def inspect
    "^#{self}^"
  end

  def to_ruby
    "-> e { (#{left.to_ruby}).call(e) + (#{right.to_ruby}).call(e) }"
  end
end

class Multiply < Struct.new(:left, :right)
  def to_s
    "#{left} * #{right}"
  end

  def inspect
    "^#{self}^"
  end

  def to_ruby
    "-> e { (#{left.to_ruby}).call(e) * (#{right.to_ruby}).call(e) }"
  end
end

class LessThan < Struct.new(:left, :right)
  def to_s
    "#{left} < #{right}"
  end

  def inspect
    "^#{self}^"
  end

  def to_ruby
    "-> e { (#{left.to_ruby}).call(e) < (#{right.to_ruby}).call(e) }"
  end
end


# 语句
# 注：对语句的求值产生的是一个新的环境，而不是一个值

class Assign < Struct.new(:name, :expression)
  def to_s
    "#{name} = #{expression}"
  end

  def inspect
    "^#{self}^"
  end

  def to_ruby
    "-> e { e.merge({ #{name.inspect} => (#{expression.to_ruby}).call(e) }) }"
  end
end

class DoNothing
  def to_s
    'do-nothing'
  end

  def inspect
    "^#{self}^"
  end

  def to_ruby
    "-> e { e }"
  end
end

class If < Struct.new(:condition, :consequence, :alternative)
  def to_s
    "if (#{condition}) { #{consequence} } else { #{alternative} }"
  end

  def inspect
    "^#{self}^"
  end

  def to_ruby
    "-> e {" +
    " if (#{condition.to_ruby}).call(e)" +
    " then (#{consequence.to_ruby}).call(e)" +
    " else (#{alternative.to_ruby}).call(e)" +
    " end }"
  end
end

class Sequence < Struct.new(:first, :second)
  def to_s
    "#{first}; #{second};"
  end

  def inspect
    "^#{self}^"
  end

  def to_ruby
    "-> e { (#{second.to_ruby}).call((#{first.to_ruby}).call(e)) }"
  end
end

class While < Struct.new(:condition, :body)
  def to_s
    "while (#{condition}) { #{body} }"
  end

  def inspect
    "^#{self}^"
  end

  def to_ruby
    "-> e {" +
    " while (#{condition.to_ruby}).call(e);" +
    " e = (#{body.to_ruby}).call(e);" +
    " end;" +
    " e; }"
  end
end
