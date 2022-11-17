require File.dirname(__FILE__) + '/expression.rb'

# 只有在直接执行当前文件时，才进行打印
def my_puts(value)
  if $0 == __FILE__
    puts value
  end
end

################################################################
# 操作语义
# 小步语义

# 语句

# 什么都不做的语句，不能规约，可用来结束语句
class DoNothing
  def to_s
    'do-nothing'
  end

  def inspect
    "^#{self}^"
  end

  def ==(other_statement)
    other_statement.instance_of?(DoNothing)
  end

  def reducible?
    false
  end
end


# 实现赋值语句 x = x + 1
# 分析 变量类、数字类、加法类都有了，需要实现一个赋值类

class Assign < Struct.new(:name, :expression)
  def to_s
    "#{name} = #{expression}"
  end

  def inspect
    "^#{self}^"
  end

  def reducible?
    true
  end

  def reduce(environment)
    if expression.reducible?
      [Assign.new(name, expression.reduce(environment)), environment]
    else
      [DoNothing.new, environment.merge({ name => expression })]
    end
  end
end

environment = { x: Number.new(2) }
statement = Assign.new(:x, Add.new(Variable.new(:x), Number.new(1)));

my_puts(statement.reducible?)
# true

statement, environment = statement.reduce(environment);
my_puts(statement)
my_puts(environment)
# x = 2 + 1
# {:x=>^2^}

statement, environment = statement.reduce(environment);
my_puts(statement)
my_puts(environment)
# x = 3
# {:x=>^2^}

statement, environment = statement.reduce(environment);
my_puts(statement)
my_puts(environment)
# do-nothing
# {:x=>^3^}

my_puts(statement.reducible?)
# false


# 语句的规约过程有变化，每次规约后都会返回环境，所以虚拟机中也需要保存环境

# 重写虚拟机
Object.send(:remove_const, :Machine)

class Machine < Struct.new(:statement, :environment)
  def step
    self.statement, self.environment = statement.reduce(environment)
  end

  def run
    while statement.reducible?
      my_puts("#{statement}, #{environment}")
      step
    end

    my_puts("#{statement}, #{environment}")
  end
end

environment = { x: Number.new(3) }
statement = Assign.new(:x, Add.new(Variable.new(:x), Number.new(5)));

Machine.new(
  statement,
  environment
).run
my_puts('####################################')


# 实现 if 语句
# if (x) { y = 1 } else { y = 2 }
# 分析：增加 If 类，入参为 条件表达式、为真时的语句、为假时的语句

class If < Struct.new(:condition, :consequence, :alternative)
  def to_s
    "if (#{condition}) { #{consequence} } else { #{alternative} }"
  end

  def inspect
    "^#{self}^"
  end

  def reducible?
    true
  end

  def reduce(environment)
    if condition.reducible?
      [If.new(condition.reduce(environment), consequence, alternative), environment]
    else
      case condition
      when Boolean.new(true)
        [ consequence, environment ]
      when Boolean.new(false)
        [ alternative, environment ]
      end
    end
  end
end

environment = { x: Boolean.new(true) }
statement = If.new(
  Variable.new(:x),
  Assign.new(:y, Number.new(1)),
  Assign.new(:y, Number.new(2))
)

my_puts(statement.reducible?)
# true

statement, environment = statement.reduce(environment);
my_puts(statement)
my_puts(environment)
# if (true) { y = 1 } else { y = 2 }
# {:x=>^true^}

statement, environment = statement.reduce(environment);
my_puts(statement)
my_puts(environment)
# y = 1
# {:x=>^true^}

statement, environment = statement.reduce(environment);
my_puts(statement)
my_puts(environment)
# do-nothing
# {:x=>^true^, :y=>^1^}

environment = { x: Boolean.new(true) }
statement = If.new(
  Variable.new(:x),
  Assign.new(:y, Number.new(1)),
  Assign.new(:y, Number.new(2))
)

Machine.new(
  statement,
  environment
).run

# 没有 else 从句的 if 语句
environment = { x: Boolean.new(false) }
statement = If.new(
  Variable.new(:x),
  Assign.new(:y, Number.new(1)),
  DoNothing.new
)

Machine.new(
  statement,
  environment
).run
my_puts('####################################')



# 实现语句按顺序执行

# x = 1;
# y = x + 2;

# 分析：增加 Sequence 类，入参为需要顺序执行的两条语句，若第一条语句执行结束（返回 DoNothing.new 实例），则执行第二个语句

class Sequence < Struct.new(:first, :second)
  def to_s
    "#{first}; #{second};"
  end

  def inspect
    "^#{self}^"
  end

  def reducible?
    true
  end

  def reduce(environment)
    case first
    when DoNothing.new
      [second, environment]
    else
      reduced_first, reduced_environment = first.reduce(environment)
      [ Sequence.new(reduced_first, second), reduced_environment]
    end
  end
end

statement = Sequence.new(
  Assign.new(:x, Number.new(1)),
  Assign.new(:y, Add.new(Variable.new(:x), Number.new(2)))
)

Machine.new(
  statement,
  {}
).run
my_puts('####################################')



# 实现循环结构语句
# while (x < 5) { x = x * 1 }
# 分析：增加 While 类，入参为 条件表达式、主体语句
# 由于是循环，每次执行完主体语句之后，都要再去执行条件表达式。所以规约后的返回值，使用顺序语句包含主题语句 + 循环本身

class While < Struct.new(:condition, :body)
  def to_s
    "while (#{condition}) { #{body} }"
  end

  def inspect
    "^#{self}^"
  end

  def reducible?
    true
  end

  def reduce(environment)
    [ If.new(condition, Sequence.new(body, self), DoNothing.new), environment ]
  end
end

Machine.new(
  While.new(
    LessThan.new(Variable.new(:x), Number.new(5)),
    Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3)))
  ),
  { x: Number.new(1) }
).run
my_puts('####################################')
