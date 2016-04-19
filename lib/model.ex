defprotocol Thoth.Model do
    def id(model)
end

defimpl Thoth.Model, for: Any do
    def id(_), do: :crypto.rand_bytes(12) |> Base.encode16
end