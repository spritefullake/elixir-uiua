defmodule UiuaTest do
  use ExUnit.Case
  doctest Uiua

  test "greets the world" do
    assert Uiua.hello() == :world
  end

  test "restack" do
    assert Uiua.restack([0, 0], [1,2,3]) == [1,1,2,3]
    assert Uiua.restack([1,0,2,2],[1,2,3]) == [2, 1, 3, 3]
    assert Uiua.restack([1,2,0], [1,2,3]) == [2,3,1]
    assert Uiua.restack([1], [1,2,3]) == [2,3]
  end
end