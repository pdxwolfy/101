munsters = {
  "Herman" => { "age" => 32, "gender" => "male" },
  "Lily" => { "age" => 30, "gender" => "female" },
  "Grandpa" => { "age" => 402, "gender" => "male" },
  "Eddie" => { "age" => 10, "gender" => "male" }
}

males = munsters.values.select { |v| v['gender'] == 'male' }
p males.map { |v| v['age'] }.reduce(0, :+)
