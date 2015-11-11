include Math
require "matrix"

class Simplex
  def initialize(function, initial_point, delta)
    p1 = initial_point
    p2 = initial_point + Vector[0.001, 0]
    p3 = initial_point + Vector[0, 0.1]
    @points = [p1, p2, p3]
    @function = function
    @prev_move_point = -1
    @delta = delta
  end

  def optimize
    while area > @delta
      step
    end
    return (1.0/3)*@points.inject(:+)
  end

  def step
    highest_point = @points.index(@points.max_by{ |coordinate|
      @function.call(coordinate)
    })
    other_points = [0, 1, 2] - [highest_point]

    if highest_point == @prev_move_point
      @points[highest_point] = (1.0/3)*@points.inject(:+)
      @prev_move_point = -1
    else
      @points[highest_point] = @points[other_points[0]] + @points[other_points[1]] - @points[highest_point]
      @prev_move_point = highest_point
    end
  end

  def area
    a = @points[1] - @points[0]
    b = @points[2] - @points[0]
    ip = a.inner_product(b)
    return 0.5*sqrt(a.norm**2*b.norm**2-ip**2)
  end
end
