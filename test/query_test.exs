defmodule Animal do
    defstruct type: :animal, kind: nil, name: nil
end

defmodule Human do
    @derive Thoth.Model
    defstruct type: :human, name: nil, age: nil
end

defimpl Thoth.Model, for: Animal do
    def id(%{name: name}) do
        name |> String.downcase |> String.to_atom
    end
end

defmodule QueryTest do
    require Thoth.Entities
    require Thoth.Query

    use ExUnit.Case

    setup_all do
        gr = :digraph.new
        o1 = Thoth.Entities.add!(gr, %Human{name: "Foo", age: 20})
        o2 = Thoth.Entities.add!(gr, %Human{name: "Bar", age: 21})
        o3 = Thoth.Entities.add!(gr, %Human{name: "Buzz", age: 19})
        o4 = Thoth.Entities.add!(gr, %Human{name: "Fuzz", age: 13})
        o5 = Thoth.Entities.add!(gr, %Human{name: "Fool", age: 20})
        o6 = Thoth.Entities.add!(gr, %Human{name: "Barl", age: 21})
        o7 = Thoth.Entities.add!(gr, %Human{name: "Buzzl", age: 19})
        o8 = Thoth.Entities.add!(gr, %Human{name: "Fuzzl", age: 13})
        o9 = Thoth.Entities.add!(gr, %Human{name: "Foor", age: 20})
        x1 = Thoth.Entities.add!(gr, %Human{name: "Barr", age: 21})
        x2 = Thoth.Entities.add!(gr, %Human{name: "Buzzr", age: 19})
        x3 = Thoth.Entities.add!(gr, %Human{name: "Fuzzr", age: 13})

        for _ <- 1..500 do
            Thoth.Entities.add!(gr, %Human{name: "Foo", age: 20})
            Thoth.Entities.add!(gr, %Human{name: "Bar", age: 21})
            Thoth.Entities.add!(gr, %Human{name: "Buzz_", age: 19})
            Thoth.Entities.add!(gr, %Human{name: "Fuzz_", age: 13})
            Thoth.Entities.add!(gr, %Human{name: "Fool", age: 20})
            Thoth.Entities.add!(gr, %Human{name: "Barl", age: 21})
            Thoth.Entities.add!(gr, %Human{name: "Buzzl", age: 19})
            Thoth.Entities.add!(gr, %Human{name: "Fuzzl", age: 13})
            Thoth.Entities.add!(gr, %Human{name: "Foor", age: 20})
            Thoth.Entities.add!(gr, %Human{name: "Barr", age: 21})
            Thoth.Entities.add!(gr, %Human{name: "Buzzr", age: 19})
            Thoth.Entities.add!(gr, %Human{name: "Fuzzr", age: 13})
        end

        a1 = Thoth.Entities.add!(gr, %Animal{name: "Fluffy",  kind: :dog})
        a2 = Thoth.Entities.add!(gr, %Animal{name: "Ruffus",  kind: :dog})
        a3 = Thoth.Entities.add!(gr, %Animal{name: "Meow", kind: :cat})
        a4 = Thoth.Entities.add!(gr, %Animal{name: "Slither", kind: :snake})

        Thoth.Entities.connect!(gr, o1, a1, :owns, :owner)
        Thoth.Entities.connect!(gr, o2, a2, :owns, :owner)
        Thoth.Entities.connect!(gr, o3, a3, :owns, :owner)
        Thoth.Entities.connect!(gr, o3, a4, :owns, :owner)
        Thoth.Entities.connect!(gr, o4, a3, :owns, :owner)
        Thoth.Entities.connect!(gr, o4, a4, :owns, :owner)
        Thoth.Entities.connect!(gr, o4, o3, :siblings, true)
        Thoth.Entities.connect!(gr, o1, o2, :friends, true)
        Thoth.Entities.connect!(gr, o1, o3, :friends, true)
        Thoth.Entities.connect!(gr, o7, o9, :friends, true)
        Thoth.Entities.connect!(gr, o1, o6, :friends, true)
        Thoth.Entities.connect!(gr, o1, o8, :friends, true)
        Thoth.Entities.connect!(gr, x1, x3, :friends, true)
        Thoth.Entities.connect!(gr, x2, o5, :friends, true)

        {:ok, graph: gr}
    end

    test "Basic finding", context do
        graph = context[:graph]
        assert length(Thoth.Query.find(graph, :human, fn %{name: name} -> String.ends_with?(name, "zz") end)) == 2
    end

    test "limited querying", context do
        graph = context[:graph]
        assert length(Thoth.Query.find(graph, :human, fn %{name: name} -> String.ends_with?(name, "zz") end, 1)) == 1
    end
end