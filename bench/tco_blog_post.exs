list = Enum.to_list(1..10_000)
# map_fun = fn(i) -> i + 1 end
map_fun = &Kernel.+(1, &1)

Benchee.run %{time: 10, warmup: 10, parallel: 1}, [
  {"map tail-recursive with ++",
   fn -> MyMap.map_tco_concat(list, map_fun) end},
  {"map with TCO reverse",
   fn -> MyMap.map_tco(list, map_fun) end},
  {"stdlib map",
   fn -> Enum.map(list, map_fun) end},
  {"map simple without TCO",
   fn -> MyMap.map_body(list, map_fun) end},
  {"map with TCO new arg order",
   fn -> MyMap.map_tco_arg_order(list, map_fun) end},
  {"map TCO no reverse",
   fn -> MyMap.map_tco_no_reverse(list, map_fun) end},
  {"map TCO overmind",
   fn -> MyMap.map_tco_over(map_fun, list) end},
  {"map TCO reversed overmind",
   fn -> MyMap.map_tco_reversed_over(map_fun, list) end},
  {"map overmind",
   fn -> MyMap.map_over(map_fun, list) end},
  {"map erlang",
   fn -> :lists.map(map_fun, list) end}
]

# Benchmark suite executing with the following configuration:
# warmup: 10.0s
# time: 10.0s
# parallel: 1
# Estimated total run time: 200.0s
#
# Benchmarking map TCO no reverse...
# Benchmarking map TCO overmind...
# Benchmarking map TCO reversed overmind...
# Benchmarking map erlang...
# Benchmarking map overmind...
# Benchmarking map simple without TCO...
# Benchmarking map tail-recursive with ++...
# Benchmarking map with TCO new arg order...
# Benchmarking map with TCO reverse...
# Benchmarking stdlib map...
#
# Name                                 ips        average    deviation         median
# map simple without TCO           3006.87       332.57μs     (±5.75%)       338.00μs
# stdlib map                       2931.59       341.11μs     (±5.55%)       345.00μs
# map TCO no reverse               2851.14       350.74μs     (±5.73%)       359.00μs
# map TCO reversed overmind        2738.95       365.10μs     (±5.72%)       374.00μs
# map with TCO new arg order       2729.02       366.43μs    (±12.44%)       368.00μs
# map erlang                       2649.13       377.48μs     (±5.57%)       386.00μs
# map overmind                     2584.41       386.94μs     (±5.62%)       395.00μs
# map with TCO reverse             2420.59       413.12μs    (±11.16%)       415.00μs
# map TCO overmind                 2315.96       431.79μs    (±24.96%)       394.00μs
# map tail-recursive with ++          4.79    208636.11μs     (±1.07%)    208862.00μs
#
# Comparison:
# map simple without TCO           3006.87
# stdlib map                       2931.59 - 1.03x slower
# map TCO no reverse               2851.14 - 1.05x slower
# map TCO reversed overmind        2738.95 - 1.10x slower
# map with TCO new arg order       2729.02 - 1.10x slower
# map erlang                       2649.13 - 1.14x slower
# map overmind                     2584.41 - 1.16x slower
# map with TCO reverse             2420.59 - 1.24x slower
# map TCO overmind                 2315.96 - 1.30x slower
# map tail-recursive with ++          4.79 - 627.34x slower
