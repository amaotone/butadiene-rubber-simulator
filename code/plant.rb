class Plant
  def initialize(n, gamma_0, coolant_temp)
    @@n = n
    @@gamma_0 = gamma_0
    @@coolant_temp = coolant_temp
  end
  def optimize
  end
end

class Reactor < Plant
  def initialize(gamma_in, gamma_out)
  end
end
