System.argv()
|> Enum.each(fn bench ->
  Code.require_file("bench/#{bench}_bench.exs")
  mod = String.to_atom("Elixir.#{Macro.camelize(bench)}Bench")

  if :erlang.function_exported(mod, :module_info, 0) do
    mod.classifiers()
    |> case do
      nil -> [nil]
      [] -> [nil]
      clas when is_list(clas) -> clas
    end
    |> Enum.each(fn cla ->
      title = "Benchmarking Classifier:  #{cla}"
      sep = String.duplicate("=", String.length(title))
      IO.puts("\n#{title}\n#{sep}\n")
      m = mod.time_mult(cla)
      actions = mod.actions(cla)
      inputs = mod.inputs(cla)

      Benchee.run(
        actions,
        [
          time: m,
          warmup: m,
          memory_time: m,
          print: %{fast_warning: false}
        ] ++ if(inputs, do: [inputs: inputs], else: [])
      )
    end)
  end
end)
