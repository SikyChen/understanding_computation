
# DFA (Deterministic Finite Automata)
# 确定性有限自动机

#
#    b         a         a,b
#    ↑↓        ↑↓         ↑↓
# -> 1 -> a -> 2 -> b -> ^3^
#

# 接受 ab aaab 拒绝 baa bbbba
# 也就是接受包含 ab 的字符串


##################################
# 规则手册

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

class DFARulebook < Struct.new(:rules)
  def next_state(state, character)
    cur = rules.detect { |rule| rule.applies_to?(state, character) }
    cur.follow
  end
end

rulebook = DFARulebook.new([
  FARule.new(1, 'a', 2), FARule.new(1, 'b', 1),
  FARule.new(2, 'a', 2), FARule.new(2, 'b', 3),
  FARule.new(3, 'a', 3), FARule.new(3, 'b', 3),
])


################################
# 有限自动机 DFA 对象

class DFA < Struct.new(:current_state, :accept_states, :rulebook)
  # 是否处于可接受状态？
  def accepting?
    accept_states.include?(current_state)
  end

  # 读取字符
  def read_character(character)
    self.current_state = rulebook.next_state(current_state, character)
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

class DFADesign < Struct.new(:start_state, :accept_states, :rulebook)
  def to_dfa
    DFA.new(start_state, accept_states, rulebook)
  end

  def accepts?(string)
    dfa = to_dfa
    dfa.read_string(string)
    dfa.accepting?
  end
end



################################
# 测试代码

puts '规则手册'
puts rulebook.next_state(1, 'a')
puts rulebook.next_state(1, 'b')
puts rulebook.next_state(2, 'b')

puts '检查是否处于可接受状态'
puts DFA.new(1, [1,3], rulebook).accepting?
puts DFA.new(1, [3], rulebook).accepting?

puts '读取字符'

dfa = DFA.new(1, [3], rulebook)
puts dfa.current_state
puts dfa.accepting?

dfa.read_character('b')
puts dfa.current_state
puts dfa.accepting?

3.times do
  dfa.read_character('a')
end
puts dfa.current_state
puts dfa.accepting?

dfa.read_character('b')
puts dfa.current_state
puts dfa.accepting?

puts '读取字符串'

dfa = DFA.new(1, [3], rulebook)
puts dfa.current_state
puts dfa.accepting?

dfa.read_string('baaab')
puts dfa.current_state
puts dfa.accepting?

puts '自动构建 DFA 实例'

dfa_design = DFADesign.new(1, [3], rulebook)
puts dfa_design.accepts?('a')
puts dfa_design.accepts?('baa')
puts dfa_design.accepts?('baba')
