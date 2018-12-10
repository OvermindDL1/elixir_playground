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

defmodule StructRecordBench do
  import AStruct1
  import AStruct9
  import ARecords

  def classifiers(), do: [:get, :put]

  def time_mult(_), do: 2

  def inputs(_) do
    nil
  end

  def actions(:get) do
    %{
      "Struct1" => fn -> news1().a end,
      "Struct9-first" => fn -> news9().a end,
      "Struct9-last" => fn -> news9().i end,
      "Record1" => fn -> aRecord1(newr1(), :a) end,
      "Record9-first" => fn -> aRecord9(newr9(), :a) end,
      "Record9-last" => fn -> aRecord9(newr9(), :i) end,
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
      "Record1" => fn -> aRecord1(newr1(), a: 42) end,
      "Record9-first" => fn -> aRecord9(newr9(), a: 42) end,
      "Record9-last" => fn -> aRecord9(newr9(), i: 42) end,
    }
  end
end
