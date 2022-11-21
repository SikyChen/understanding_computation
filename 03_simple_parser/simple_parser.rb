# 使用操作语义

require File.dirname(__FILE__) + '/../01_operational_semantic/02.big_step_semantic/simple.rb'
require 'treetop'

Treetop.load('simple')

parser = SimpleParser.new

parse_tree = parser.parse('while (x < 5) { x = x * 3 }')
puts parse_tree

statement = parse_tree.to_ast

puts '语句是'
puts statement

puts '操作语义-大步语义'
puts statement.evaluate({ x: Number.new(1) })

################################################################
#
# treetop 是一种将源代码，通过类正则表达式进行语法分析后，将源代码转为 AST 语法书的工具
# 我们在 treetop 文件中，书写类正则的语法规则，交由 Treetop.load 方法加载
#
# 例如
# 定义 While，当 treetop 工具通过类正则匹配到 'while (' condition:expression ') { ' body:statement ' }' 时，会生成一个对应的语法树
# 我们在 While 后面的大括号中，定义了一个 to_ast 方法，那么生成的语法树就具有该方法
# 使用 parse_tree.to_ast 调用该方法时，则会使用我们预先定义的 While 操作语义类生成 ruby 语法树
# 由于 ruby 语法树可以通过 Machine 机器或 evaluate 方法来执行计算，则可以得到源代码的计算结果了
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
# 调用 Ruby 对象上的 evaluate 方法进行计算获得结果
#
#
# 上述过程已经是一个简单的编译过程，虽然没有从源代码生成一种新代码，但是已经将一种未知的源代码转为已知的 ruby AST 语法树，
# 并且可通过 ruby 环境对该语法树执行计算，已经可以达到编译并执行的目的了。
#
################################################################
