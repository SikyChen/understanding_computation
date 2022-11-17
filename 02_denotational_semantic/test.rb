require File.dirname(__FILE__) + '/simple.rb'

number_to_ruby = Number.new(4).to_ruby
boolean_to_ruby = Boolean.new(false).to_ruby

puts number_to_ruby
puts boolean_to_ruby

# 使用 ruby 的 eval 方法，执行 simple 语言通过指称语义转化后的 ruby 字符串
puts eval(number_to_ruby).call({ a: 2, x: 7 })
puts eval(boolean_to_ruby).call({ a: 2, x: 7 })

variable_to_ruby = Variable.new(:a).to_ruby
puts variable_to_ruby
puts eval(variable_to_ruby).call({ a: 2, x: 7 })

add_to_ruby = Add.new(Variable.new(:x), Number.new(2)).to_ruby
puts add_to_ruby
puts eval(add_to_ruby).call({ a: 2, x: 7 })

lessthen_to_ruby = LessThan.new(Variable.new(:x), Multiply.new(Number.new(3), Variable.new(:a))).to_ruby
puts lessthen_to_ruby
puts eval(lessthen_to_ruby).call({ a: 2, x: 7 })

assign_to_ruby = Assign.new(:b, Add.new(Variable.new(:a), Number.new(3))).to_ruby
puts assign_to_ruby
puts eval(assign_to_ruby).call({ a: 2, x: 7 })

puts eval(DoNothing.new.to_ruby).call({x: 3})

if_to_ruby = If.new(
  Variable.new(:x),
  Assign.new(:y, Number.new(3)),
  Assign.new(:y, Number.new(24))
).to_ruby
puts if_to_ruby
puts eval(if_to_ruby).call({ x: false })


