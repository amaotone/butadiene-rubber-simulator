require "benchmark"
require "./plant"
require "./optimize"

f = lambda{ |conditions|
  gamma_0 =conditions[0]
  t2 =conditions[1]
  plant = Plant.new(5,  gamma_0, t2)
  plant.costs[:total]
}

result = nil
time = Benchmark.realtime do
  simplex = Simplex.new(f, Vector[0.03, 260], 1e-12)
  result = simplex.optimize()
end

puts "min cost: #{f.call(result).round(2)}"
puts "gamma_0: #{result[0].round(4)}"
puts "T2: #{result[1].round(1)}"
puts "time: #{time}"
