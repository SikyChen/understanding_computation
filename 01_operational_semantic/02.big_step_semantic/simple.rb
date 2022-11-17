require File.dirname(__FILE__) + '/../01.small_step_semantic/statement.rb'

# 只有在直接执行当前文件时，才进行打印
def my_puts(value)
  if $0 == __FILE__
    puts value
  end
end

################################################################
# 操作语义
# 大步语义
# 通过对表达式、语句设置直接计算结果的 evaluate 方法，来让 ruby 程序递归的计算出结果，而不需要 Machine 机器来推进计算

# 表达式

# 大步语义中，数值、Boolean不需要再规约，直接返回它们自己即可
class Number
  def evaluate(environment)
    self
  end
end

class Boolean
  def evaluate(environment)
    self
  end
end

# 变量，直接从环境中查找并返回即可
class Variable
  def evaluate(environment)
    environment[name]
  end
end

# 加法，分别计算左右 表达式/值 的结果，再加起来就行了
class Add
  def evaluate(environment)
    Number.new(left.evaluate(environment).value + right.evaluate(environment).value)
  end
end

class Multiply
  def evaluate(environment)
    Number.new(left.evaluate(environment).value * right.evaluate(environment).value)
  end
end

class LessThan
  def evaluate(environment)
    Boolean.new(left.evaluate(environment).value < right.evaluate(environment).value)
  end
end

my_puts(
  Number.new(23).evaluate({})
)
my_puts(
  Variable.new(:x).evaluate({ x: Number.new(23)})
)
my_puts(
  LessThan.new(
    Add.new(Variable.new(:x), Number.new(2)),
    Variable.new(:y)
  ).evaluate({
    x: Number.new(2),
    y: Number.new(5)
  })
)


my_puts('################################')
# 语句
# 大步语义的语句求值过程，总是把 【语句+当前环境】 转成一个 【新的环境】

# DoNothing 语句就是返回一个未改变的环境
class DoNothing
  def evaluate(environment)
    environment
  end
end

# 赋值 语句就是返回一个改变的新环境
class Assign
  def evaluate(environment)
    environment.merge({ name => expression.evaluate(environment) })
  end
end

statement = Assign.new(:x, Number.new(4))
my_puts(statement)
env = statement.evaluate({})
my_puts(env)

# if 语句，判断条件后执行对应语句，并且返回该语句改变后的新环境
class If
  def evaluate(environment)
    case condition.evaluate(environment)
    when Boolean.new(true)
      consequence.evaluate(environment)
    when Boolean.new(false)
      alternative.evaluate(environment)
    end
  end
end

statement = If.new(
  LessThan.new(Number.new(100), Variable.new(:x)),
  Assign.new(:y, Number.new(5)),
  Assign.new(:y, Number.new(6)),
)
my_puts(statement)
env = statement.evaluate(env)
my_puts(env)

# Sequence 语句顺序执行，需要把第一个语句执行后的结果环境，作为第二个语句执行的环境
class Sequence
  def evaluate(environment)
    second.evaluate(first.evaluate(environment))
  end
end

statement = Sequence.new(
  Assign.new(:x, Number.new(8)),
  Assign.new(:z, Number.new(10))
)
my_puts(statement)
env = statement.evaluate(env)
my_puts(env)

# While
class While
  def evaluate(environment)
    case condition.evaluate(environment)
    when Boolean.new(true)
      evaluate(body.evaluate(environment))
    when Boolean.new(false)
      environment
    end
  end
end

statement = While.new(
  LessThan.new(Variable.new(:z), Number.new(13)),
  Assign.new(:z, Add.new(Variable.new(:z), Number.new(1)))
)
my_puts(statement)
env = statement.evaluate(env)
my_puts(env)
