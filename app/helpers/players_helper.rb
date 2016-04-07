module PlayersHelper
  def alphabet
    thing = (10...36).map{ |i| i.to_s 36 }
    thing += ['.', '+', '-', '_']
    thing += (1...10).map{ |i| i.to_s }
    thing += ['0']
    thing
  end
end
