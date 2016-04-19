defmodule Bar do
    @derive Thoth.Model
    defstruct type: :bar, age: nil
end

defmodule EntityTest do
    require Thoth.Entities
    use ExUnit.Case

    setup do
        gr = :digraph.new

        {:ok, graph: gr}
    end

    test "Basic add and update", context do
        graph = context[:graph]
        vid = Thoth.Entities.add!(graph, %Bar{age: 5})
        node = Thoth.Entities.get_vertex(graph, vid)
        assert node.age === 5
        Thoth.Entities.update!(graph, vid, %Bar{node|age: 3})
        node = Thoth.Entities.get_vertex(graph, vid)
        assert node.age === 3        
    end
end