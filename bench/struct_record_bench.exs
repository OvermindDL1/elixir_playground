defmodule AStruct1 do
  defstruct [a: 1]
  def news1(), do: %__MODULE__{}
end

defmodule AStruct9 do
  defstruct [a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8, i: 9]
  def news9(), do: %__MODULE__{}
end

defmodule ARecords do
  import Record
  defrecord :aRecord1, [a: 1]
  defrecord :aRecord9, [a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8, i: 9]
  def newr1(), do: aRecord1()
  def newr9(), do: aRecord9()
end

defmodule BRecord do
  defmacro __using__(fields) do
    # Add more helpers and flesh out functions and checks if this should ever be actually 'used'
    mappings = fields|>Enum.map(&elem(&1, 0))|>Enum.with_index(1)
    ast_new = [quote do def new() do {__MODULE__, unquote_splicing(Enum.map(fields, &elem(&1, 1)))} end end]
    ast_fields = [quote do def fields() do unquote(fields) end end]
    ast_field = Enum.map(mappings, fn {k, i} ->
      quote do defmacro field(unquote(k)) do unquote(i) end end
    end) ++ [quote do defmacro field(k) do quote do unquote(__MODULE__).field_idx(unquote(k)) end end end]
    ast_field_idx = Enum.map(mappings, fn {k, i} -> quote do def field_idx(unquote(k)), do: unquote(i) end end)
    ast_get = [quote do defmacro get(r, k) do quote do elem(unquote(r), unquote(__MODULE__).field(unquote(k))) end end end]
    ast_put = [quote do defmacro put(r, k, v) do quote do put_elem(unquote(r), unquote(__MODULE__).field(unquote(k)), unquote(v)) end end end]
    {:__block__, [], ast_new++ast_fields++ast_field++ast_field_idx++ast_get++ast_put}
  end

  defmacro get(r, k) do
    quote do
      r = unquote(r)
      elem(r, elem(r, 0).field_idx(unquote(k)))
    end
  end

  defmacro put(r, k, v) do
    quote do
      r = unquote(r)
      put_elem(r, elem(r, 0).field_idx(unquote(k)), unquote(v))
    end
  end
end

defmodule ARecord1 do
  use BRecord, [a: 1]
end

defmodule ARecord9 do
  use BRecord, [a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8, i: 9]
end

defmodule StructRecordBench do
  import AStruct1
  import AStruct9
  import ARecords
  require BRecord
  require ARecord1
  require ARecord9

  def classifiers(), do: [:get, :put]

  def time(_), do: 2

  def inputs(_) do
    nil
  end

  def actions(:get) do
    %{
      "Struct1" => fn -> news1().a end,
      "Struct9-first" => fn -> news9().a end,
      "Struct9-last" => fn -> news9().i end,
      "Record1-stock" => fn -> aRecord1(newr1(), :a) end,
      "Record1-remote" => fn -> ARecord1.new() |> BRecord.get(:a) end,
      "Record1-direct" => fn -> ARecord1.new() |> ARecord1.get(:a) end,
      "Record9-first-stock" => fn -> aRecord9(newr9(), :a) end,
      "Record9-first-remote" => fn -> ARecord9.new() |> BRecord.get(:a) end,
      "Record9-first-direct" => fn -> ARecord9.new() |> ARecord9.get(:a) end,
      "Record9-last-stock" => fn -> aRecord9(newr9(), :i) end,
      "Record9-last-remote" => fn -> ARecord9.new() |> BRecord.get(:i) end,
      "Record9-last-direct" => fn -> ARecord9.new() |> ARecord9.get(:i) end,
    }
  end

  def actions(:put) do
    %{
      "Struct1" => fn -> %{news1() | a: 42} end,
      "Struct1-opt" => fn -> %AStruct1{news1() | a: 42} end,
      "Struct9-first" => fn -> %{news9() | a: 42} end,
      "Struct9-first-opt" => fn -> %AStruct9{news9() | a: 42} end,
      "Struct9-last" => fn -> %{news9() | i: 42} end,
      "Struct9-last-opt" => fn -> %AStruct9{news9() | i: 42} end,
      "Record1-stock" => fn -> aRecord1(newr1(), a: 42) end,
      "Record1-remote" => fn -> ARecord1.new() |> BRecord.put(:a, 42) end,
      "Record1-direct" => fn -> ARecord1.new() |> ARecord1.put(:a, 42) end,
      "Record9-first-stock" => fn -> aRecord9(newr9(), a: 42) end,
      "Record9-first-remote" => fn -> ARecord9.new() |> BRecord.put(:a, 42) end,
      "Record9-first-direct" => fn -> ARecord9.new() |> ARecord9.put(:a, 42) end,
      "Record9-last-stock" => fn -> aRecord9(newr9(), i: 42) end,
      "Record9-last-remote" => fn -> ARecord9.new() |> BRecord.put(:i, 42) end,
      "Record9-last-direct" => fn -> ARecord9.new() |> ARecord9.put(:i, 42) end,
    }
  end
end
