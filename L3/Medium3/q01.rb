def fun_with_ids
  a_outer = 42             # (id001, 42)
  b_outer = "forty two"    # (id002, "forty two")
  c_outer = [42]           # (id003, [42])
  d_outer = c_outer[0]     # (id001, 42)

  a_outer_id = a_outer.object_id # id001
  b_outer_id = b_outer.object_id # id002
  c_outer_id = c_outer.object_id # id003
  d_outer_id = d_outer.object_id # id001

  puts "a_outer is #{a_outer} with an id of: #{a_outer_id} before the block."
  puts "           42                        #{a_outer_id}" #id001
  puts "b_outer is #{b_outer} with an id of: #{b_outer_id} before the block."
  puts "           forty two                 #{b_outer_id}" #id002
  puts "c_outer is #{c_outer} with an id of: #{c_outer_id} before the block."
  puts "           [42]                      #{c_outer_id}" #id003
  puts "d_outer is #{d_outer} with an id of: #{d_outer_id} before the block.\n\n"
  puts "           42                        #{d_outer_id}" #id001
  puts a_outer_id != b_outer_id
  puts a_outer_id != c_outer_id
  puts a_outer_id == d_outer_id
  puts b_outer_id != c_outer_id
  puts b_outer_id != d_outer_id
  puts c_outer_id != d_outer_id

  1.times do
    a_outer_inner_id = a_outer.object_id # id001
    b_outer_inner_id = b_outer.object_id # id002
    c_outer_inner_id = c_outer.object_id # id003
    d_outer_inner_id = d_outer.object_id # id001

    puts "a_outer id was #{a_outer_id} before the block and is: #{a_outer.object_id} inside the block.", "    " + (a_outer_id == a_outer.object_id).to_s # id001
    puts "b_outer id was #{b_outer_id} before the block and is: #{b_outer.object_id} inside the block.", "    " + (b_outer_id == b_outer.object_id).to_s # id002
    puts "c_outer id was #{c_outer_id} before the block and is: #{c_outer.object_id} inside the block.", "    " + (c_outer_id == c_outer.object_id).to_s # id003
    puts "d_outer id was #{d_outer_id} before the block and is: #{d_outer.object_id} inside the block.", "    " + (d_outer_id == d_outer.object_id).to_s, '' # id001

    a_outer = 22                 # id004
    b_outer = "thirty three"     # id005
    c_outer = [44]               # id006
    d_outer = c_outer[0]         # id007

    puts "a_outer inside after reassignment is #{a_outer} with an id of: #{a_outer_id} before and: #{a_outer.object_id} after.", a_outer_id != a_outer.object_id
    puts "b_outer inside after reassignment is #{b_outer} with an id of: #{b_outer_id} before and: #{b_outer.object_id} after.", b_outer_id != b_outer.object_id
    puts "c_outer inside after reassignment is #{c_outer} with an id of: #{c_outer_id} before and: #{c_outer.object_id} after.", c_outer_id != c_outer.object_id
    puts "d_outer inside after reassignment is #{d_outer} with an id of: #{d_outer_id} before and: #{d_outer.object_id} after.\n", d_outer_id != d_outer.object_id, "\n"


    a_inner = a_outer
    b_inner = b_outer
    c_inner = c_outer
    d_inner = c_inner[0]

    a_inner_id = a_inner.object_id
    b_inner_id = b_inner.object_id
    c_inner_id = c_inner.object_id
    d_inner_id = d_inner.object_id

    puts "a_inner is #{a_inner} with an id of: #{a_inner_id} inside the block (compared to #{a_outer.object_id} for outer)."
    puts "b_inner is #{b_inner} with an id of: #{b_inner_id} inside the block (compared to #{b_outer.object_id} for outer)."
    puts "c_inner is #{c_inner} with an id of: #{c_inner_id} inside the block (compared to #{c_outer.object_id} for outer)."
    puts "d_inner is #{d_inner} with an id of: #{d_inner_id} inside the block (compared to #{d_outer.object_id} for outer).\n\n"
  end

  puts '============================================================================='
  puts "a_outer is #{a_outer} with an id of: #{a_outer_id} BEFORE and: #{a_outer.object_id} AFTER the block."
  puts "b_outer is #{b_outer} with an id of: #{b_outer_id} BEFORE and: #{b_outer.object_id} AFTER the block."
  puts "c_outer is #{c_outer} with an id of: #{c_outer_id} BEFORE and: #{c_outer.object_id} AFTER the block."
  puts "d_outer is #{d_outer} with an id of: #{d_outer_id} BEFORE and: #{d_outer.object_id} AFTER the block.\n\n"

  puts "a_inner is #{a_inner} with an id of: #{a_inner_id} INSIDE and: #{a_inner.object_id} AFTER the block." rescue "ugh ohhhhh"
  puts "b_inner is #{b_inner} with an id of: #{b_inner_id} INSIDE and: #{b_inner.object_id} AFTER the block." rescue "ugh ohhhhh"
  puts "c_inner is #{c_inner} with an id of: #{c_inner_id} INSIDE and: #{c_inner.object_id} AFTER the block." rescue "ugh ohhhhh"
  puts "d_inner is #{d_inner} with an id of: #{d_inner_id} INSIDE and: #{d_inner.object_id} AFTER the block.\n\n" rescue "ugh ohhhhh"
end

fun_with_ids
