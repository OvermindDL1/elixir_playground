list = Enum.to_list(1..100_000)
# map_fun = fn(i) -> i + 1 end
map_fun = &Kernel.*(2, &1)

defmodule EnumBench do
  def map(list, transformer) do
    list
    |> :lists.reverse
    |> map(transformer, [])
  end

  defp map([ ], _, acc), do: acc
  defp map([ head | tail ], transformer, acc),
    do: map(tail, transformer, [ transformer.(head) | acc ])
end

Benchee.run %{time: 10, warmup: 10, parallel: 1}, [
  {"Enum",
   fn -> Enum.map(list, map_fun) end},
 {"rolled",
   fn -> EnumBench.map(list, map_fun) end}
]

