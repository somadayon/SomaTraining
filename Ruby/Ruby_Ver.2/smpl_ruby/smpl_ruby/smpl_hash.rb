# coding: utf-8

#
puts "hash:宣言(初期化)と要素追加"
h={}
h["hoge"]=123
h["foo" ]=456
h["piyo"]=789
p h
puts

puts "hash:イテレーション"
h.each{|k,v|
  printf("key:%s  value:%s\n",k,v)
}
puts

puts "hash:key列挙"
p h.keys
puts

puts "hash:keyでイテレーション（さらにソートあり）"
h.keys.sort.each{|k|
  printf("key:%s  value:%s\n",k,h[k])
}
puts

# hash    : 初期化　要素の追加　イテレーション　キー列挙　宣言
