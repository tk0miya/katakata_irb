require 'test_helper'

class TestScope < Minitest::Test
  Types = KatakataIrb::Types
  BaseScope = KatakataIrb::BaseScope
  Scope = KatakataIrb::Scope
  NIL = Types::NIL
  A, B, C, D, E, F, G, H, I, J, K = ('A'..'K').map do |name|
    klass = Class.new
    klass.define_singleton_method(:inspect) { name }
    Types::InstanceType.new(klass)
  end

  def assert_type(expected_types, type)
    assert_equal [*expected_types].map(&:klass).to_set, type.types.map(&:klass).to_set
  end

  def base_scope
    BaseScope.new(binding, Object.new)
  end

  def test_lvar
    scope = Scope.new base_scope
    scope['a'] = A
    assert_equal A, scope['a']
  end

  def test_conditional
    scope = Scope.new base_scope
    scope.conditional do |sub_scope|
      sub_scope['a'] = A
    end
    assert_type [A, NIL], scope['a']
  end

  def test_branch
    scope = Scope.new base_scope
    scope['c'] = A
    scope['d'] = B
    scope.run_branches(
      -> { _1['a'] = _1['c'] = _1['d'] = C },
      -> { _1['a'] = _1['b'] = _1['d'] = D },
      -> { _1['a'] = _1['b'] = _1['d'] = E },
      -> { _1['a'] = _1['b'] = _1['c'] = F; _1.terminate }
    )
    assert_type [C, D, E], scope['a']
    assert_type [NIL, D, E], scope['b']
    assert_type [A, C], scope['c']
    assert_type [C, D, E], scope['d']
  end

  def test_nested_scope
    scope = Scope.new base_scope
    scope['a'] = A
    scope['b'] = A
    scope['c'] = A
    sub_scope = Scope.new scope, { 'c' => B }
    assert_type A, sub_scope['a']

    assert_type A, sub_scope['b']
    assert_type B, sub_scope['c']
    sub_scope['a'] = C
    sub_scope.conditional { _1['b'] = C }
    sub_scope['c'] = C
    assert_type C, sub_scope['a']
    assert_type [A, C], sub_scope['b']
    assert_type C, sub_scope['c']
    scope.update sub_scope
    assert_type C, scope['a']
    assert_type [A, C], scope['b']
    assert_type A, scope['c']
  end

  def test_break
    scope = Scope.new base_scope
    scope['a'] = A
    breakable_scope = Scope.new scope, { Scope::BREAK_RESULT => nil }
    breakable_scope.conditional do |sub|
      sub['a'] = B
      assert_type [B], sub['a']
      sub.terminate_with Scope::BREAK_RESULT, C
      sub['a'] = C
      assert_type [C], sub['a']
    end
    assert_type [A], breakable_scope['a']
    breakable_scope[Scope::BREAK_RESULT] = D
    breakable_scope.merge_jumps
    assert_type [C, D], breakable_scope[Scope::BREAK_RESULT]
    scope.update breakable_scope
    assert_type [A, B], scope['a']
  end
end
