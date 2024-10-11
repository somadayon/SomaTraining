# coding: utf-8

# ----------------------------------------
# array 配列
# ----------
puts "array:宣言"
a = [] # 宣言
p a
puts

puts "array:追加"
p a
a.push("zzz")
a.push("hoge")
a.push("foo")
a.push("piyo")
p a
puts

printf("配列の要素数:%d\n", a.size ) # 要素の数（配列長)
puts

puts "array:イテレーション（通常）"
a.each{|itm|
  p itm
}
puts

puts "array:イテレーション（index番号付）"
a.each_with_index{|itm,i|
  printf("idx:%d [%s]\n",i,itm)
}
puts

puts "array:末尾へのアクセス"
p a[-1]
puts

puts "array:内容更新"
p a
a[1]="modified"
p a
puts

puts "array:ソート"
p a
p a.sort
puts

puts "array:uniq"
a.push("hoge")
a.push("hoge")
a.push("hoge")
a.push("hoge")
p a
a.uniq!
p a
puts

puts "array:delete(\"foo\")"
p a
a.delete("foo")
p a
puts
puts "array:delete_at(1)"
p a
a.delete_at(1)
puts

puts "array:push(123)" # 末尾に追加
p a
a.push(123)
p a
puts

puts "array:pop" # 末尾を取り出し
p a
itm = a.pop
p a
puts

puts "array:unshift(321)"
p a
a.unshift(321) # 先頭に追加
p a
puts

puts "array:shift"
p a
first_item = a.shift # 先頭を取り出し
#p first_item
p a
puts



# ----------------------------------------

