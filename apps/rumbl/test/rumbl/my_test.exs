defmodule MyTest do
  use ExUnit.Case, async: true

  setup do
    # run some tedious setup code
    :ok
  end

  test "pass" do
    assert true
  end

  test "pass with falses" do
    assert false == false
  end
end
