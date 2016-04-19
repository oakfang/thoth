defmodule Thoth.Async do
    defp recv_loop(vids, 0), do: vids

    defp recv_loop(vids, n) do
        receive do
            {:ok, vid} -> recv_loop([vid|vids], n - 1)
            _ -> recv_loop(vids, n - 1)
        end
    end

    defp spawn_chunk(graph, loop, filter, vtype, vids) do
        spawn_link(fn ->
            Enum.each vids, fn vid ->
                case :digraph.vertex(graph, vid) do
                    {^vid, %{type: ^vtype}=node} ->
                        if filter.(node) do
                            send(loop, {:ok, vid})
                        else
                            send(loop, nil)
                        end
                    _ -> send(loop, nil)
                end
            end
        end)
    end

    defp remote_filter(graph, loop, filter, vtype, [v1, v2, v3, v4, v5, v6, v7, v8, v9, v10|vids]) do
        spawn_chunk(graph, loop, filter, vtype, [v1, v2, v3, v4, v5, v6, v7, v8, v9, v10])
        remote_filter(graph, loop, filter, vtype, vids)
    end

    defp remote_filter(_, _, _, _, []), do: nil

    defp remote_filter(graph, loop, filter, vtype, vids) do
        spawn_chunk(graph, loop, filter, vtype, vids)
    end

    def find(graph, vtype, filter) do
        parent = self()
        rcv = spawn_link fn -> send(parent, recv_loop([], :digraph.no_vertices(graph))) end
        remote_filter(graph, rcv, filter, vtype, :digraph.vertices(graph))
        receive do
            vids -> vids
        end
    end

    def find(graph, vtype) do
        find(graph, vtype, fn _ -> true end)
    end
end