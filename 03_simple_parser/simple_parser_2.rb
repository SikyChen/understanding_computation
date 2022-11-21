# 使用指称语义

require File.dirname(__FILE__) + '/../02_denotational_semantic/simple.rb'

require 'treetop'

Treetop.load('simple')

parser = SimpleParser.new

parse_tree = parser.parse('while (x < 5) { x = x * 3 }')
puts parse_tree

statement = parse_tree.to_ast

puts '语句是'
puts statement

puts '指称语义'
puts statement.to_ruby
puts eval(statement.to_ruby).call({x: 1})

################################################################
#
# treetop 是一种将源代码，通过类正则表达式进行语法分析后，将源代码转为 AST 语法书的工具
# 我们在 treetop 文件中，书写类正则的语法规则，交由 Treetop.load 方法加载
#
# 例如
# 定义 While，当 treetop 工具通过类正则匹配到 'while (' condition:expression ') { ' body:statement ' }' 时，会生成一个对应的语法树
# 我们在 While 后面的大括号中，定义了一个 to_ast 方法，那么生成的语法树就具有该方法
# 使用 parse_tree.to_ast 调用该方法时，则会使用我们预先定义的 While 指称语义类生成 ruby 语法树
# ruby 语法树可以通过 to_ruby 方法来转换成 ruby 代码，再使用 ruby 环境对新代码求值即可
#
# 整体流程大致如下
#
# 源代码
#  |
# 经过 parser (treetop的语法分析)
#  |
# 产生 源代码 AST
#  |
# 经过 to_ast 方法转换
#  |
# 产生 新代码 AST (这里是 Ruby AST)
#  |
# 调用 Ruby 对象上的 to_ruby 方法
#  |
# 生成 ruby 的可执行代码
#  |
# 使用 ruby 的 eval 方法执行计算
#
#
# 上述过程将一种未知的源代码转为了可执行的 ruby 代码，是一个完整的编译过程了。
#
# 与 Super Tiny Compiler 不同的是
# 没有直接使用遍历源代码字符的方式来进行词法分析，而是使用类似正则的方式，通过匹配来对源代码进行解析
#
#
################################################################
