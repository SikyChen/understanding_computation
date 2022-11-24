
# NFA (Not Deterministic Finite Automata)
# 非确定性有限自动机
# 自由移动

#
#    a,b
#    ↑↓
# -> 1 -> b -> 2 -> a,b -> 3 -> a,b -> ^4^
#

# 接受 bab aaabaa 拒绝 baaa bbaba
# 也就是只接受倒数第三个字符为 b 的字符串


##################################
# 规则手册

require 'set'

class FARule < Struct.new(:state, :character, :next_state)
  def inspect
    "#<FARule #{state.inspect} --> #{character} --> #{next_state.inspect}>"
  end

  def applies_to?(state, character)
    state === self.state && character === self.character
  end

  def follow
    next_state
  end
end

class NFARulebook < Struct.new(:rules)
  def next_states(states, character)
    states.flat_map { |state|
      rules.select { |rule| rule.applies_to?(state, character) }
        .map(&:follow)
    }.to_set
  end
end


################################
# 非确定性有限自动机 NFA 对象

class NFA < Struct.new(:current_states, :accept_states, :rulebook)
  # 是否处于可接受状态？
  def accepting?
    (current_states & accept_states).any?
  end

  # 读取字符
  def read_character(character)
    self.current_states = rulebook.next_states(current_states, character)
  end

  # 读取字符串
  def read_string(string)
    string.chars.each do |character|
      read_character(character)
    end
  end
end


################################
# 自动构建 DFA 实例

class NFADesign < Struct.new(:start_state, :accept_states, :rulebook)
  def accepts?(string)
    nfa = NFA.new(start_state, accept_states, rulebook)
    nfa.read_string(string)
    nfa.accepting?
  end
end



################################
# 自由移动

class NFARulebook
  def follow_free_moves(states)
    more_states = next_states(states, nil)

    if more_states.subset?(states)
      states
    else
      follow_free_moves(states + more_states)
    end
  end
end

class NFA
  def current_states
    rulebook.follow_free_moves(super)
  end
end



################################
# 测试代码

# 非确定性有限自动机
puts '非确定性有限自动机'
rulebook = NFARulebook.new([
  FARule.new(1, 'a', 1), FARule.new(1, 'b', 1), FARule.new(1, 'b', 2),
  FARule.new(2, 'a', 3), FARule.new(2, 'b', 3),
  FARule.new(3, 'a', 4), FARule.new(3, 'b', 4)
])

puts '规则手册'
puts rulebook.next_states(Set[1], 'b')
puts rulebook.next_states(Set[1, 2], 'a')
puts rulebook.next_states(Set[1, 3], 'b')

puts '检查是否处于可接受状态'
puts NFA.new(Set[1], [4], rulebook).accepting?
puts NFA.new(Set[1, 4], [4], rulebook).accepting?

puts '读取字符'

nfa = NFA.new(Set[1], [4], rulebook);
puts nfa.current_states
puts nfa.accepting?

nfa.read_character('b')
puts nfa.current_states
puts nfa.accepting?

nfa.read_character('a')
puts nfa.current_states
puts nfa.accepting?

nfa.read_character('b')
puts nfa.current_states
puts nfa.accepting?

puts '读取字符串'

nfa = NFA.new(Set[1], [4], rulebook);
puts nfa.current_states
puts nfa.accepting?

nfa.read_string('babb')
puts nfa.current_states
puts nfa.accepting?

puts '自动构建 nfa 实例'

nfa_design = NFADesign.new(Set[1], [4], rulebook)
puts nfa_design.accepts?('a')
puts nfa_design.accepts?('baa')
puts nfa_design.accepts?('baba')


# 自由移动
puts '自由移动'
puts '规则手册'
rulebook = NFARulebook.new([
  FARule.new(1, nil, 2), FARule.new(1, nil, 4),
  FARule.new(2, 'a', 3),
  FARule.new(3, 'a', 2),
  FARule.new(4, 'a', 5),
  FARule.new(5, 'a', 6),
  FARule.new(6, 'a', 4)
])

puts rulebook.next_states(Set[1], nil)

puts rulebook.follow_free_moves(Set[1])

nfa_design = NFADesign.new(Set[1], [2, 4], rulebook)
puts nfa_design.accepts?('aa')
puts nfa_design.accepts?('aaa')
puts nfa_design.accepts?('aaaaa')
puts nfa_design.accepts?('aaaaaa')
