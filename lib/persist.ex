defmodule Thoth.Persistence do
    def auto_persist(graph, path, interval) do
        :timer.apply_interval(interval, Thoth.Persistence, :save, [graph, path])
    end

    def delete graph do
        :digraph.delete(graph)
    end

    def save graph, path do
        {_, t1, t2, t3, _} = graph
        :ok = :ets.tab2file(t1, path ++ '.t1.data')
        :ok = :ets.tab2file(t2, path ++ '.t2.data')
        :ok = :ets.tab2file(t3, path ++ '.t3.data')
    end

    def load, do: :digraph.new

    def load(path) do
        case :ets.file2tab(path ++ '.t1.data') do
            {:ok, t1} ->
                :ets.file2tab(path ++ '.t1.data')
                {:ok, t2} = :ets.file2tab(path ++ '.t2.data')
                {:ok, t3} = :ets.file2tab(path ++ '.t3.data')
                {:digraph, t1, t2, t3, true}
            _ -> :digraph.new
        end
    end

    def load(path, interval) do
        g = load path
        auto_persist(g, path, interval)
        g
    end
end