# coding: utf-8
puts "関数"

def func0
  puts "func0() が呼ばれました"
end

def func1(a,b)
  return a+b
end

puts "func0 を呼ぶ"
func0
puts

puts "func1(100,200) を呼ぶ"
ans = func1(100,200)
printf("ans: %d\n",ans)
puts


