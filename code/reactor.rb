include Math
require "./const"

class Reactor
  attr_accessor :power, :heat, :volume
  def initialize(gamma_0, gamma_in, gamma_out, volume, flow_rate, coolant_temp)
    @gamma_0 = gamma_0
    @gamma_in = gamma_in
    @gamma_out = gamma_out
    @volume = volume
    @flow_rate = flow_rate
    @coolant_temp = coolant_temp
    @diameter = (volume/(ALPHA*2*PI))**(1.0/3)*2
    @height = @diameter*ALPHA
    @surface = @diameter*PI*@height
    calc_power(0)
  end

  def calc_power(power)
    heat_of_reaction = HEAT_OF_POLY*(@flow_rate*DENSITY*(@gamma_in-@gamma_out)/3.6)/BUTADIENE_M
    heat =  heat_of_reaction + power
    h = heat/@surface/(REACTION_TEMP-@coolant_temp)

    # viscosity [Pa s]
    viscosity = ((POLYMER_LENGTH)**1.7)*((1-(@gamma_out/@gamma_0))**2.5)*exp(21.0*@gamma_0)*1e-3

    # dimensionless numbers
    pr = viscosity*TOLUENE_SPECIFIC_HEAT/THERMAL_CONDUCTIVITY
    nu = h*@diameter/THERMAL_CONDUCTIVITY
    re = (2*nu/pr**(1/3.0))**1.5

    # power consumption
    revolution = re*viscosity/DENSITY/(@diameter/2)**2
    np = 14.6*re**(-0.28)
    power_new = np*DENSITY*(revolution**3)*(@diameter/2)**5

    if (power_new - power).abs < ACCURACY
      @reynolds = re
      @revolution = revolution
      @power = power_new
      @heat = heat
    else
      return calc_power(power_new)
    end
  rescue SystemStackError
    @reynolds = nil
    @revolution = nil
    @power = nil
    @heat = nil
  end
end
