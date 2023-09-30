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
    assert Uiua.run("+ 1 2") == [3]
    assert Uiua.run("+1 [2 3 4]") == [3, 4, 5]
  end

  test "not" do
    assert Uiua.not([0]) == [1]
    assert Uiua.not([1]) == [0]
    assert Uiua.not([[0, 1, 1, 0]]) == [[1, 0, 0, 1]]
  end
end
