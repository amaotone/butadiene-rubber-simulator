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
    @n = n
    @feed = feed
    @visc = ((ML)**1.7)*(CV**2.5)*exp(21.0*feed)*1e-3  # viscosity [Pa s]
    @speed = GP/(RHO*CV*feed)  # feed speed [m3 h-1]
    @volume = @speed*TAU/n
    @diameter = (@volume/(ALPHA*2*PI))**(1/3.0)*2
    @height = @diameter*ALPHA
    @coolant = coolant
  end

  def calc()
    tpc = 0  # total power consumption
    prop = (1-CV)**(1.0/@n)  # proportional constant
    puts "results under (N, feed, T2)="+
      "("+@n.to_s+", "+@feed.to_s+", "+@coolant.to_s+")"
    for n in 1..@n
      puts "#"+n.to_s
      tpc += reactor(@feed*(prop**(n-1)),@feed*(prop**n))
    end
    puts "total"
    puts "Ptot = "+tpc.round(3).to_s+"[W]"
  end

  def reactor(cin, cout)
    # heat transfer rate
    h = HP*(@speed*RHO*(cin-cout)*1000/3600)/M/(@diameter*PI*@height)/(T1-@coolant)

    # dimensionless numbers
    pr = @visc*CP/TC
    nu = h*@diameter/TC
    re = (2*nu/pr**(1/3.0))**1.5
    puts "Re = "+re.round(3).to_s

    # revolution number
    revnum = re*@visc/RHO/(@diameter/2)**2
    puts "n = "+revnum.round(3).to_s+"[rps]"

    # power consumption
    np = 14.6*re**(-0.28)
    p = np*RHO*(revnum**3)*(@diameter/2)**5
    puts "P = "+p.round(3).to_s+"[W]"

    return p
  end
end

puts "input n[-], feed[wt%], T2[K]"
n       = gets.to_i
feed    = gets.to_f
coolant = gets.to_i

plant = Plant.new(n, feed, coolant)
plant.calc()
