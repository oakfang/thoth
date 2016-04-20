defmodule Thoth.Async do
    defp recv_loop(vids, 0), do: vids

    defp recv_loop(vids, n) do
        receive do
            {:ok, vid} -> recv_loop([vid|vids], n - 1)
            _ -> recv_loop(vids, n - 1)
        end
    end

    defp limited_recv_loop(vids, 0), do: vids

    defp limited_recv_loop(vids, n) do
        receive do
            {:ok, vid} -> limited_recv_loop([vid|vids], n - 1)
            _ -> limited_recv_loop(vids, n)
        end
    end

    defp spawn_chunk(graph, loop, filter, vtype, vids) do
        spawn_link(fn ->
            Enum.each vids, fn vid ->
                try do
                    case :digraph.vertex(graph, vid) do
                        {^vid, %{type: ^vtype}=node} ->
                            if filter.(node) do
                                send(loop, {:ok, vid})
                            else
                                send(loop, nil)
                            end
                        _ -> send(loop, nil)
                    end
                rescue
                    ArgumentError -> Process.exit(self(), :normal)
                end
            end
        end)
    end

    defp remote_filter(_, _, _, _, [], _), do: nil

    defp remote_filter(graph, loop, filter, vtype, vids, chunk_size) do
        spawn_chunk(graph, loop, filter, vtype, Enum.take(vids, chunk_size))
        remote_filter(graph, loop, filter, vtype, Enum.drop(vids, chunk_size), chunk_size)
    end

    def find(graph, vtype, filter) do
        parent = self()
        rcv = spawn_link fn -> send(parent, recv_loop([], :digraph.no_vertices(graph))) end
        remote_filter(graph, rcv, filter, vtype, :digraph.vertices(graph), round(Float.ceil(:digraph.no_vertices(graph) / 10.5)))
        receive do
            vids -> vids
        end
    end

    def find(graph, vtype, filter, limit) do
        parent = self()
        rcv = spawn_link fn -> send(parent, limited_recv_loop([], limit)) end
        remote_filter(graph, rcv, filter, vtype, :digraph.vertices(graph), round(Float.ceil(:digraph.no_vertices(graph) / 10.5)))
        receive do
            vids -> vids
        end
    end

    def find(graph, vtype) do
        find(graph, vtype, fn _ -> true end)
    end
end