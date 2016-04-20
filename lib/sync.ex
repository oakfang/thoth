defmodule Thoth.Sync do
    def find(graph, vtype, filter) when is_function(filter, 1) do
        Enum.filter(:digraph.vertices(graph), fn vid ->
            case :digraph.vertex(graph, vid) do
                {^vid, %{type: ^vtype}=n} -> filter.(n)
                _ -> false
            end
        end)
    end

    def find(graph, vtype) do
        find(graph, vtype, fn _ -> true end)
    end
end