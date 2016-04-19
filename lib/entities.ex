defmodule Thoth.Entities do
    require Thoth.Model

    def connect!(graph, source, target, type), do: connect!(graph, source, target, type, false) 
    def connect!(graph, source, target, type, mutual) when is_boolean(mutual) do
        if mutual do
            connect!(graph, source, target, type, type)
        else
            :digraph.add_edge(graph, source, target, type)
        end
    end

    def connect!(graph, source, target, type, reverse) when is_atom(reverse) do
        {:digraph.add_edge(graph, source, target, type),
         :digraph.add_edge(graph, target, source, reverse)}
    end

    defp disconnect_by_filter!(graph, source, filter) do
        :digraph.del_edges graph, :digraph.out_edges(graph, source)
            |> Enum.map(&(:digraph.edge(graph, &1)))
            |> Enum.filter_map(filter,
                               fn ({e, _, _, _}) -> e end)
    end

    def disconnect!(graph, source, target) do
        disconnect_by_filter!(graph, source, fn ({_, _, v, _}) -> v === target end)
    end

    def disconnect!(graph, source, target, type) do
        disconnect_by_filter!(graph, source, fn ({_, _, v, l}) -> l === type and v === target end)
    end

    def add!(graph, node), do: :digraph.add_vertex(graph, Thoth.Model.id(node), node)
    
    def update!(graph, vid, node), do: :digraph.add_vertex(graph, vid, node)

    def delete!(graph, vid), do: :digraph.del_vertex(graph, vid)

    def get_connections(graph, vid, type, select \\ true) do
        :digraph.out_edges(graph, vid)
            |> Enum.map(&(:digraph.edge(graph, &1)))
            |> Enum.filter_map(fn ({_, _, _, l}) -> l === type end,
                               fn ({_, _, v, _}) -> :digraph.vertex(graph, v) end)
            |> Enum.map(fn ({v, node}) -> 
                if select do
                    node
                else
                    v
                end
               end)
    end

    def get_connection(graph, vid, type, select \\ true) do
        {_, _, target, _} = :digraph.out_edges(graph, vid)
                                |> Enum.map(&(:digraph.edge(graph, &1)))
                                |> Enum.find(fn ({_, _, _, l}) -> l === type end)
        if select do
            get_vertex(graph, target)
        else
            target
        end
    end

    def has_connection?(graph, source, target, type) do
        edges = :digraph.out_edges(graph, source)
                    |> Enum.map(&(:digraph.edge(graph, &1)))
                    |> Enum.filter(fn ({_, _, v, l}) -> l === type and v === target end)
        case edges do
            [] -> false
            _ -> true
        end
    end

    def has_vertex?(graph, vid) do
        case :digraph.vertex(graph, vid) do
            {_, _} -> true
            _ -> false
        end
    end

    def get_vertex(graph, vid) do
       case :digraph.vertex(graph, vid) do
            {^vid, node} -> node
            _ -> nil
        end 
    end
end