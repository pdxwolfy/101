ages = { "Herman" => 32, "Lily" => 30, "Grandpa" => 402, "Eddie" => 10 }

WHO = "Spot"
puts ages.key? WHO
puts ages.any? { |who, _| who == WHO }
puts !ages.assoc(WHO).nil?
puts !ages.fetch(WHO, nil).nil?
