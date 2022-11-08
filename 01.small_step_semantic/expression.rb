

# 只有在直接执行当前文件时，才进行打印
def my_puts(value)
  if $0 == __FILE__
    puts value
  end
end

################################################################
# 操作语义
# 小步语义

# 表达式

# (1×2) + (3×4)

# 根据上面的表达式，规定出几种类型，用来生成AST语法树

class Number < Struct.new(:value)
end

class Add < Struct.new(:left, :right)
end

class Multiply < Struct.new(:left, :right)
end

Add.new(
  Multiply.new(Number.new(1), Number.new(2)),
  Multiply.new(Number.new(3), Number.new(4))
)


# 类型的 inspect 方法打印的内容结构太过复杂，通过重定义 inspect 来简化输出

class Number
  def to_s
    value.to_s
  end

  def inspect
    "^#{self}^"
  end
end

class Add
  def to_s
    "#{left} + #{right}"
  end

  def inspect
    "^#{self}^"
  end
end

class Multiply
  def to_s
    "#{left} * #{right}"
  end

  def inspect
    "^#{self}^"
  end
end

Add.new(
  Multiply.new(Number.new(1), Number.new(2)),
  Multiply.new(Number.new(3), Number.new(4))
)

# => ^1 * 2 + 3 * 4^


# 给类实现 reducible? 方法，用于表示该类型是否可规约
# 可规约 == 表达式，还需要进一步计算
# 不可规约 == 值

class Number
  def reducible?
    false
  end
end

class Add
  def reducible?
    true
  end
end

class Multiply
  def reducible?
    true
  end
end


# 如果是可规约的类型，则通过类上的 reduce 方法进行规约
# 使用从左到右的方式进行规约，例如 Add
# 1. 先判断 left 是否可规约，若是则计算 left 后再执行 Add
# 2. 再判断 right 是否可规约，若是则计算 right 后再执行 Add
# 3. 若 left 和 right 都不可规约，则将 left.value 和 right.value 相加并返回

class Add
  def reduce
    if left.reducible?
      Add.new(left.reduce, right)
    elsif right.reducible?
      Add.new(left, right.reduce)
    else
      Number.new(left.value + right.value)
    end
  end
end

class Multiply
  def reduce
    if left.reducible?
      Multiply.new(left.reduce, right)
    elsif right.reducible?
      Multiply.new(left, right.reduce)
    else
      Number.new(left.value * right.value)
    end
  end
end

expression = Add.new(
  Multiply.new(Number.new(1), Number.new(2)),
  Multiply.new(Number.new(3), Number.new(4))
)

my_puts(expression)
expression.reducible?
# => true

expression = expression.reduce
# => ^2 + 3 * 4^

my_puts(expression)
expression.reducible?
# => true

expression = expression.reduce
# => ^2 + 12^

my_puts(expression)
expression.reducible?
# => true

expression = expression.reduce
# => ^14^

my_puts(expression)
expression.reducible?
# => false


# 上面的小步语义，都是手动调用的，最终得到了 Number.new(14) 这个结果
# 要让程序自动的运行，可以把这些代码和状态封装到一个类里
# 称之为 虚拟机

class Machine < Struct.new(:expression)
  def step
    self.expression = expression.reduce
  end

  def run
    while expression.reducible?
      my_puts(expression)
      step
    end

    my_puts(expression)
  end
end

my_puts('表达式： (1×2) + (3×4)')
Machine.new(Add.new(
  Multiply.new(Number.new(1), Number.new(2)),
  Multiply.new(Number.new(3), Number.new(4))
)).run
my_puts('####################################')


# 扩展

# 布尔值
class Boolean < Struct.new(:value)
  def to_s
    value.to_s
  end

  def inspect
    "^#{self}^"
  end

  def reducible?
    false
  end
end

# 小于
class LessThan < Struct.new(:left, :right)
  def to_s
    "#{left.to_s} < #{right.to_s}"
  end

  def inspect
    "^#{self}^"
  end

  def reducible?
    true
  end

  def reduce
    if left.reducible?
      LessThan.new(left.reduce, right)
    elsif right.reducible?
      LessThan.new(left, right.reduce)
    else
      Boolean.new(left.value < right.value)
    end
  end
end

my_puts('表达式：  5 < 2 + 1')
Machine.new(
  LessThan.new(
    Number.new(5),
    Add.new(
      Number.new(2),
      Number.new(1)
    )
  )
).run
my_puts('####################################')


# 支持变量
# 变量用于映射到它的值，所以它是可规约的，规约的结果就是返回它的值
# 使用一个散列表hash作为`环境`来存储变量，key为变量名，值为变量所映射的值，可以是可规约的表达式，也可以是不可规约的值

class Variable < Struct.new(:name)
  def to_s
    name.to_s
  end

  def inspect
    "^#{self}^"
  end

  def reducible?
    true
  end

  def reduce(environment)
    environment[name]
  end
end

# 定义一个环境
environment = { x: Number.new(3), y: Number.new(4) }

# 有了环境之后，再进行表达式计算时，就不再只传入类似 Number.new(3) 这样表示字面值的对象了
# 而是希望能够传入变量进行计算，所以需要对其他类的 reduce 进行修改，以支持传入变量

class Add
  def reduce(environment)
    if left.reducible?
      Add.new(left.reduce(environment), right)
    elsif right.reducible?
      Add.new(left, right.reduce(environment))
    else
      Number.new(left.value + right.value)
    end
  end
end

class Multiply
  def reduce(environment)
    if left.reducible?
      Multiply.new(left.reduce(environment), right)
    elsif right.reducible?
      Multiply.new(left, right.reduce(environment))
    else
      Number.new(left.value * right.value)
    end
  end
end

class LessThan
  def reduce(environment)
    if left.reducible?
      LessThan.new(left.reduce(environment), right)
    elsif right.reducible?
      LessThan.new(left, right.reduce(environment))
    else
      Boolean.new(left.value < right.value)
    end
  end
end

# 重写 Machine 方法以支持传入 environment
Object.send(:remove_const, :Machine)

class Machine < Struct.new(:expression, :environment)
  def step
    self.expression = expression.reduce(environment)
  end

  def run
    while expression.reducible?
      my_puts(expression)
      step
    end

    my_puts('结果是：')
    my_puts(expression)
  end
end

my_puts('环境：')
my_puts(environment)

my_puts('表达式：  x + y')

expression = Add.new(
  Variable.new(:x),
  Variable.new(:y)
)

Machine.new(
  expression,
  environment
).run
my_puts('####################################')
