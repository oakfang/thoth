defmodule Thoth.Sync do
    defp limited_filter([], _, _) do
        []
    end

    defp limited_filter(_, 0, _) do
        []
    end

    defp limited_filter([first|rest], limit, fun) do
        if fun.(first) do
            [first|limited_filter(rest, limit - 1, fun)]
        else
            limited_filter(rest, limit, fun)
        end
    end

    defp finder(graph, vtype, filter, filterer) do
        filterer.(:digraph.vertices(graph), fn vid ->
            case :digraph.vertex(graph, vid) do
                {^vid, %{type: ^vtype}=n} -> filter.(n)
                _ -> false
            end
        end)
    end

    def find(graph, vtype, filter) when is_function(filter, 1) do
        finder(graph, vtype, filter, &Enum.filter/2)
    end

    def find(graph, vtype, filter, limit) when is_function(filter, 1) do
        finder(graph, vtype, filter, fn (enum, ftr) -> limited_filter(enum, limit, ftr) end)
    end

    def find(graph, vtype) do
        find(graph, vtype, fn _ -> true end)
    end
end