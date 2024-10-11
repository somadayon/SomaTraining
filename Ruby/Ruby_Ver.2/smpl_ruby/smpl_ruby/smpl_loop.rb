# coding: utf-8
#
# coding: utf-8

# ----------------------------------------
# ループ処理
# ----------
puts "loop:配列のイテレーション each"
a = [10,20,30,80,100] 
a.each{|val|
  p val
}
puts
puts "loop:配列のイテレーション each_with_index"
a.each_with_index{|val,i|
  printf("idx:%d  val:%d\n",i,val)
}
puts

puts "loop: timesで回数指定の繰り返し"
10.times{|i|
  printf("%d\n",i)
}
puts

puts "loop: stepで範囲指定の繰り返し　例：5で開始、13まで回す、2刻み"
5.step(13,2){|i|
  printf("%d\n",i)
}
puts

puts "loop: for文は使用禁止"
puts "  理由：終端処理を間違えやすい、{} が使えない(end縛り)"
#for i in [3,4,5]
#  p i
#end

# ----------------------------------------

