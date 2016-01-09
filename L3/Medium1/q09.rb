munsters = {
  "Herman" => { "age" => 32, "gender" => "male" },
  "Lily" => { "age" => 30, "gender" => "female" },
  "Grandpa" => { "age" => 402, "gender" => "male" },
  "Eddie" => { "age" => 10, "gender" => "male" },
  "Marilyn" => { "age" => 23, "gender" => "female"},
  "Billy" => { "age" => 17, "gender" => "female"},
  "Joey" => { "age" => 18, "gender" => "male"}
}

munsters.each_value do |v|
  v['agegroup'] = case v['age']
                  when 0...18
                    'kid'
                  when 18...65
                    'adult'
                  else
                    'senior'
                  end
end

require 'pp'
pp munsters
