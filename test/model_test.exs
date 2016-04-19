defmodule Foo do
    @derive Thoth.Model
    defstruct type: :foo, name: nil
end

defmodule ModelTest do
    require Thoth.Model
    use ExUnit.Case

    test "Default id function works" do
      assert String.length(Thoth.Model.id(%Foo{})) === 24
    end
end