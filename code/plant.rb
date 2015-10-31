include Math
require "./const"
require "./reactor"

class Plant
  def initialize(n, gamma_0, coolant_temp)
    @n = n
    @gamma_0 = gamma_0
    @coolant_temp = coolant_temp
    @reactors = []
    @costs = {}

    flow_rate = PRODUCT_FLOW_RATE/CONVERSION/DENSITY/gamma_0  # feed speed [m3 h-1]
    k = (1.0/(1-CONVERSION)-1)/RESIDENCE_TIME  # reaction constant [h-1]
    tau = (1.0/k)*((1-CONVERSION)**(-1.0/n)-1)  # residence time
    volume = flow_rate*tau  # [m3]

    prop = (1-CONVERSION)**(1.0/n)
    for i in 0...n
      gamma_in = gamma_0*(prop**(i))
      gamma_out = gamma_0*(prop**(i+1))
      @reactors << Reactor.new(gamma_0, gamma_in, gamma_out, volume, flow_rate, coolant_temp)
    end
    calc_cost()
  end

  def show()
    @reactors.each do |reactor|
      reactor.show()
    end
  end

  def calc_cost()
    total_power = 0
    total_heat = 0
    @reactors.each do |reactor|
      total_power += reactor.power
      total_heat += reactor.heat
    end

    @costs[:electricity] = ELECTRICITY_PRICE*total_power/(1000*3600)  # [yen s-1]

    toluene_wt = (PRODUCT_FLOW_RATE/CONVERSION)*((1-@gamma_0)/@gamma_0)/3600 # [kg s-1]
    toluene_heat = toluene_wt*TOLUENE_LATENT_HEAT  # [J s-1]
    steam_heat = toluene_heat/THERMAL_EFFICIENCY  # [J s-1]
    steam_wt = steam_heat/WATER_LATENT_HEAT  # [kg s-1]
    @costs[:steam] = (steam_wt/1000)*STEAM_PRICE  # [yen s-1]

    reactor_price = (40000000.0+5.1e6*@reactors[0].volume)*@n
    @costs[:reactor] = reactor_price/(5*330*24*3600)  # [yen s-1]

    coolant_wt = total_heat/(WATER_SPECIFIC_HEAT*WATER_TEMP_RISE)/1000  # [ton s-1]
    @costs[:coolant] = coolant_price(@coolant_temp)*coolant_wt  # [yen s-1]

    @costs[:total] = @costs[:electricity] + @costs[:steam] + @costs[:reactor] + @costs[:coolant]
  end

  def coolant_price(t)
    #TODO: hard coding. it should be rewrittend
    t = t-273
    case
    when t>30
      return nil
    when t>10
      return 15+(45-15)*((30-t)*1.0/(30-10))
    when t>0
      return 45+(65-45)*((10-t)*1.0/(10-0))
    when t>-10
      return 65+(90-65)*((0-t)*1.0/(0+10))
    when t>=-20
      return 90+(140-90)*((-10-t)*1.0/(-10+20))
    else
      return nil
    end
  end

  def optimize()
  end
end
