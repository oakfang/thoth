defmodule Foo do
    @derive Thoth.Model
    defstruct type: :foo, name: nil
end

defmodule ModelTest do
    require Thoth.Model
    use ExUnit.Case

    test "Default id function works" do
        id = Thoth.Model.id(%Foo{})
        assert String.at(id, 14) === "4"
        assert String.length(id) === 36
    end
end