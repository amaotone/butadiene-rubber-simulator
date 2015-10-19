include Math

GP = (63.0*1000/24)  # product flow rate [kg h-1]
ML = 50.0  # polymer length
TAU = 5.0  # residence time
RHO = 850.0  # density [kg m-3]
ALPHA = 1.3  # height/diameter of reactor
HP = (72.8*1000)  # heat of polymerization [J mol-1]
CV = 0.6  # conversion
T1 = (273+50)  # [K]
TC = 0.128  # thermal conductivity [W m-1 K-1]
CP = (1.68*1000)  # specific heat of toluene [J kg-1 K-1]
M = 54.0  # molecular weight of butadiene [g mol-1]

class Plant
  def initialize(n, feed, coolant)
    @n = n  # number of reactors [-]
    @feed = feed  # feed [wt%]
    @rate = GP/(RHO*CV*feed)  # flow rate [m3 h-1]
    @volume = @rate*TAU/n  # [m3]
    @diameter = (@volume/(ALPHA*2*PI))**(1/3.0)*2  # [m]
    @height = @diameter*ALPHA  # [m]
    @coolant = coolant  # T2 [K]
  end

  def calc()
    tpc = 0  # total power consumption [W]
    prop = (1-CV)**(1.0/@n)  # proportional constant [-]

    for n in 1..@n
      tpc += reactor(@feed*(prop**(n-1)),@feed*(prop**n))
    end

    return ((tpc)/1000).round(2)
  end

  def reactor(gamma_in, gamma_out)
    # viscosity [Pa s]
    visc = ((ML)**1.7)*((1-(gamma_out/@feed))**2.5)*exp(21.0*@feed)*1e-3

    # heat transfer rate
    h = HP*(@rate*RHO*(gamma_in-gamma_out)*1000/3600)/M/(@diameter*PI*@height)/(T1-@coolant)

    # dimensionless numbers
    pr = visc*CP/TC
    nu = h*@diameter/TC
    re = (2*nu/pr**(1/3.0))**1.5

    # revolution number
    revnum = re*visc/RHO/(@diameter/2)**2

    # power consumption
    np = 14.6*re**(-0.28)
    p = np*RHO*(revnum**3)*(@diameter/2)**5

    return p
  end
end

coolant = 258
for feed in 2..10
  f = feed*0.01
  for n in 1..5
    plant = Plant.new(n, f, coolant)
    print plant.calc().to_s + "\t"
  end
  print "\n"
end
