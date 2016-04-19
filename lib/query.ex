defmodule Thoth.Query do
    defp query_shallow_flat(graph, vids, edge_type) when is_atom(edge_type) do
        Enum.flat_map(vids, fn vid ->
            :digraph.out_edges(graph, vid)
            |> Enum.map(&(:digraph.edge(graph, &1)))
            |> Enum.filter_map(fn ({_, _, _, l}) -> l === edge_type end, 
                               fn ({_, _, v, _}) -> v end)
        end) 
            |> Enum.uniq
    end

    defp query_shallow_flat(graph, vids, step) do
        case step do
            {edge_type, filter} ->
                Enum.flat_map(vids, fn vid ->
                    :digraph.out_edges(graph, vid)
                    |> Enum.map(&(:digraph.edge(graph, &1)))
                    |> Enum.filter_map(fn ({_, _, v, l}) -> 
                        l === edge_type and case :digraph.vertex(graph, v) do
                            {_, n} -> filter.(n)
                            _ -> false
                        end 
                    end, fn ({_, _, v, _}) -> v end)
                end) 
                    |> Enum.uniq
            _ -> []
        end
    end

    def query(_, vids, []) when is_list(vids), do: vids

    def query(graph, vids, [step|path]) when is_list(vids) do
        query(graph, query_shallow_flat(graph, vids, step), path)
    end

    def query(graph, vid, path), do: query(graph, [vid], path)

    def find(graph, vtype) do
        Enum.filter(:digraph.vertices(graph), fn vid ->
            case :digraph.vertex(graph, vid) do
                {^vid, %{type: ^vtype}} -> true
                _ -> false
            end
        end)
    end

    def find(graph, vtype, filter) when is_function(filter, 1) do
        Enum.filter(:digraph.vertices(graph), fn vid ->
            case :digraph.vertex(graph, vid) do
                {^vid, %{type: ^vtype}=n} -> filter.(n)
                _ -> false
            end
        end)
    end
end