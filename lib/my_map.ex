defmodule MyMap do
  def map(list, function) do
    Enum.reverse _map([], list, function)
  end

  defp _map(acc, [head | tail], function) do
    _map([function.(head) | acc], tail, function)
  end


  defp _map(acc, [], _function) do
    acc
  end

  def map2(acc \\ [], list, function)

  def map2(acc, [head | tail], function) do
    map2(acc ++ [function.(head)], tail, function)
  end

  def map2(acc, [], _function) do
    acc
  end

  def map3([], _func), do: []

  def map3([head | tail], func) do
    [func.(head) | map(tail, func)]
  end
end
