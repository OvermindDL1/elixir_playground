System.argv()
|> Enum.each(fn bench ->
  try do
    Code.require_file("bench/#{bench}_bench.exs")
    mod = String.to_atom("Elixir.#{Macro.camelize(bench)}Bench")

    if :erlang.function_exported(mod, :module_info, 0) do
      if(:erlang.function_exported(mod, :classifiers, 0), do: mod.classifiers(), else: [nil])
      |> case do
        nil -> [nil]
        [] -> [nil]
        clas when is_list(clas) -> clas
      end
      |> Enum.each(fn cla ->
        if cla do
          title = "Benchmarking Classifier: #{cla}"
          sep = String.duplicate("=", String.length(title))
          IO.puts("\n#{title}\n#{sep}\n")
        end

        setup = if(:erlang.function_exported(mod, :setup, 1), do: mod.setup(cla), else: nil)

        m =
          cond do
            :erlang.function_exported(mod, :time, 2) -> mod.time(cla, setup)
            :erlang.function_exported(mod, :time, 1) -> mod.time(cla)
            true -> 5
          end

        inputs =
          cond do
            :erlang.function_exported(mod, :inputs, 2) -> mod.inputs(cla, setup)
            :erlang.function_exported(mod, :inputs, 1) -> mod.inputs(cla)
            true -> nil
          end

        actions =
          cond do
            :erlang.function_exported(mod, :actions, 2) -> mod.actions(cla, setup)
            true -> mod.actions(cla)
          end

        Benchee.run(
          actions,
          [
            time: m,
            warmup: m,
            memory_time: m,
            print: %{fast_warning: false}
          ] ++ if(inputs, do: [inputs: inputs], else: [])
        )

        if(:erlang.function_exported(mod, :teardown, 2), do: mod.teardown(cla, setup))
      end)
    end
  rescue
    r -> IO.puts("Unknown exception: #{Exception.format(:error, r, __STACKTRACE__)}")
  catch
    {type, reason} when type in [:throw, :exit] -> IO.puts("Unknown error: #{Exception.format(type, reason, __STACKTRACE__)}")
    e -> IO.puts("Unknown error: #{Exception.format(:throw, e, __STACKTRACE__)}")
  end
end)
