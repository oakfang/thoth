defprotocol Thoth.Model do
    def id(model)
end

defimpl Thoth.Model, for: Any do
    use Bitwise

    def id(_) do
        <<a1, a2, a3, a4>> <> <<b1, b2>> <> <<c1, c2>> <> <<d1, d2>> <> <<e1, e2, e3, e4, e5, e6>> = :crypto.rand_bytes(16)
        seg_a = <<a1, a2, a3, a4>> |> Base.encode16 |> String.downcase
        seg_b = <<b1, b2>> |> Base.encode16 |> String.downcase
        c1 = c1 &&& 0x4f ||| 0x40
        seg_c = <<c1, c2>> |> Base.encode16 |> String.downcase
        d1 = d1 &&& 0xbf ||| 0x80
        seg_d = <<d1, d2>> |> Base.encode16 |> String.downcase
        seg_e = <<e1, e2, e3, e4, e5, e6>> |> Base.encode16 |> String.downcase
        seg_a <> "-" <> seg_b <> "-" <> seg_c <> "-" <> seg_d <> "-" <> seg_e
    end
end