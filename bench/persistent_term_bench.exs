defmodule BenchDefs do
  def range(:ints), do: 1..1000

  def range(:binaries32),
    do: unquote(Enum.map(1..1000, fn _ -> :crypto.strong_rand_bytes(32) end))
end

defmodule HeadDispatch do
  for i <- [BenchDefs.range(:binaries32), BenchDefs.range(:ints)], j <- i do
    def match(unquote(j)), do: unquote(j)
  end
end

defmodule PersistentTermBench do
  def classifiers(), do: [:ints, :binaries32]

  def time(_), do: 2

  def inputs(cla),
    do: %{
      "First" => BenchDefs.range(cla) |> Enum.into([]) |> List.last(),
      "Last" => BenchDefs.range(cla) |> Enum.into([]) |> List.last()
    }

  def setup(cla) do
    Enum.each(BenchDefs.range(cla), &:persistent_term.put(&1, &1))
    tab = :ets.new(PersistentTermBench, [])
    Enum.each(BenchDefs.range(cla), &:ets.insert_new(tab, {&1}))
    tab
  end

  def teardown(_, tab) do
    :ets.delete(tab)
  end

  def actions(_, tab),
    do: %{
      ":persistent_term" => fn inp -> :persistent_term.get(inp) end,
      ":ets" => fn inp -> :ets.lookup(tab, inp) end,
      "HeadDispatch" => fn inp -> HeadDispatch.match(inp) end
    }
end
