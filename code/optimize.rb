require "matrix"
require "benchmark"
require "timeout"
require "csv"

DEBUG = false

ANALYTICAL_SOLUTION = Vector[1.0, 1.0]
STEP = 0.0005
DELTA = 0.00025
EPSILON = 0.001
TIMEOUT = 3.0
TOLERANCE = 0.01

TIMEOUT_CSV_PATH = "./timeouts.csv"

f = lambda{ |coordinate|
  x=coordinate[0]
  y=coordinate[1]
  (x-1)**2+50*(y-1)**2
}

g = lambda{ |coordinate|
  x=coordinate[0]
  y=coordinate[1]
  (x-1)**2+100*(x**3-y)**2
}

# use steepest descent method
def optimize(func, coordinate)
  begin
    # grad f
    vector = Vector[
      (func.call(coordinate+Vector[DELTA, 0.0])-func.call(coordinate-Vector[DELTA, 0.0]))/DELTA/2,
      (func.call(coordinate+Vector[0.0, DELTA])-func.call(coordinate-Vector[0.0, DELTA]))/DELTA/2
    ]

    coordinate = line_search(func, coordinate, -STEP*vector)
  end while vector.norm > EPSILON
  puts coordinate if DEBUG
  return coordinate
end

# go straight until value increase
def line_search(func, coordinate, vector)
  while func.call(coordinate+vector) < func.call(coordinate)
    coordinate += vector
  end
  return coordinate
end

def benchmark(func, n)
  pass_num = 0
  fail_num = 0
  timeout_num = 0
  total_time = 0
  timeouts = []
  # optimize test 100 times
  for i in 1..n
    print "#{i}: "

    # start from random coordinate
    x = Random.rand(-2.0..2.0).round(3)
    y = Random.rand(-2.0..2.0).round(3)
    start = Vector[x, y]
    result = Vector[0, 0]

    begin
      timeout(TIMEOUT) {
        time = Benchmark.realtime do
          result = optimize(func, start)
        end

        if (result-ANALYTICAL_SOLUTION).norm < TOLERANCE
          pass_num += 1
          total_time += time
          print "pass in #{time.round(3)}s"
        else
          fail_num += 1
          print "fail => result: #{result}"
        end
      }
    rescue Timeout::Error
      print "timeout => start: #{start}"
      timeout_num += 1
      timeouts << start
    end

    print "\n"
  end
  puts "pass: #{pass_num}"
  puts "fail: #{fail_num}"
  puts "timeout: #{timeout_num}"
  puts "average time: #{(total_time/pass_num).round(3)}s"

  CSV.open(TIMEOUT_CSV_PATH, "wb") do |csv|
    timeouts.each do |vector|
      csv << [vector[0], vector[1]]
    end
  end
  puts "output timeout vectors"
end

# start = Vector[0,0]
# time = Benchmark.realtime do
#   result =optimize(g, start)
# end
# puts "#{time} sec"
benchmark(g, 10000)
