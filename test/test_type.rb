require 'test_helper'

class TestType < Minitest::Test
  def test_type_inspect
    true_type = KatakataIrb::Types::TRUE
    false_type = KatakataIrb::Types::FALSE
    nil_type = KatakataIrb::Types::NIL
    string_type = KatakataIrb::Types::STRING
    true_or_false = KatakataIrb::Types::UnionType[true_type, false_type]
    array_type = KatakataIrb::Types::InstanceType.new Array, { Elem: true_or_false }
    assert_equal 'nil', nil_type.inspect
    assert_equal 'true', true_type.inspect
    assert_equal 'false', false_type.inspect
    assert_equal 'String', string_type.inspect
    assert_equal 'Array', KatakataIrb::Types::InstanceType.new(Array).inspect
    assert_equal 'true | false', true_or_false.inspect
    assert_equal 'Array[Elem: true | false]', array_type.inspect
    assert_equal 'Array', array_type.inspect_without_params
    assert_equal 'Proc', KatakataIrb::Types::PROC.inspect
    assert_equal 'Array.itself', KatakataIrb::Types::SingletonType.new(Array).inspect
  end

  def test_type_from_object
    obj = Object.new
    arr = [1, 'a']
    hash = { 'key' => :value }
    int_type = KatakataIrb::Types.type_from_object 1
    obj_type = KatakataIrb::Types.type_from_object obj
    arr_type = KatakataIrb::Types.type_from_object arr
    hash_type = KatakataIrb::Types.type_from_object hash

    assert_equal Integer, int_type.klass
    # Use singleton_class to autocomplete singleton methods
    assert_equal obj.singleton_class, obj_type.klass
    # Array and Hash are special
    assert_equal Array, arr_type.klass
    assert_equal Hash, hash_type.klass
    assert_equal 'Object', obj_type.inspect
    assert_equal 'Array[Elem: Integer | String]', arr_type.inspect
    assert_equal 'Hash[K: String, V: Symbol]', hash_type.inspect
    assert_equal 'Array.itself', KatakataIrb::Types.type_from_object(Array).inspect
    assert_equal 'KatakataIrb.itself', KatakataIrb::Types.type_from_object(KatakataIrb).inspect
  end
end
