defmodule UiuaTest do
  use ExUnit.Case
  doctest Uiua

  test "greets the world" do
    assert Uiua.hello() == :world
  end

  test "restack" do
    assert Uiua.restack([0, 0], [1, 2, 3]) == [1, 1, 2, 3]
    assert Uiua.restack([1, 0, 2, 2], [1, 2, 3]) == [2, 1, 3, 3]
    assert Uiua.restack([1, 2, 0], [1, 2, 3]) == [2, 3, 1]
    assert Uiua.restack([1], [1, 2, 3]) == [2, 3]
  end

  test "restack one argument is same as two argument restack" do
    assert Uiua.restack([[0, 0], 1, 2, 3]) == Uiua.restack([0, 0], [1, 2, 3])
    assert Uiua.restack([[1, 0, 2, 2], 1, 2, 3]) == Uiua.restack([1, 0, 2, 2], [1, 2, 3])
    assert Uiua.restack([[1, 2, 0], 1, 2, 3]) == Uiua.restack([1, 2, 0], [1, 2, 3])
    assert Uiua.restack([[1], 1, 2, 3]) == Uiua.restack([1], [1, 2, 3])
  end

  test "add" do
    assert Uiua.add([1, 2]) == [3]
    assert Uiua.add([1, [2, 3, 4]]) == [[3, 4, 5]]
    assert Uiua.add([[1, 2, 3], [4, 5, 6]]) == [[5,7,9]]
  end

  test "not" do
    assert Uiua.not([0]) == [1]
    assert Uiua.not([1]) == [0]
    assert Uiua.not([[0, 1, 1, 0]]) == [[1, 0, 0, 1]]
  end

  test "generic list same size" do
    assert Stack.same_size_lists([[1,1], [2,3], [4,5]]) == true
    assert Stack.same_size_lists([1, [2], [4]]) == false
  end

  test "elementwise operate" do
    assert Stack.elementwise_operate(fn x, y -> x + y end, [[1,2,3], [4,5,6]]) == [5,7,9]
  end
end
