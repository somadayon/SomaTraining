# coding: utf-8
puts "ファイルIO"
puts

puts "hoge.txt を生成"
fp=open("./hoge.txt","w")    # ひらく
fp.print("hoge\nfoo\nbar\n") # 書き込み
fp.close                     # 閉じる
p `cat hoge.txt` # 中身を表示
puts

puts "hoge.txt を読み込み"
ary=[]
fp=open("./hoge.txt")
fp.each{|line|
  line.chomp! # 末尾の改行を捨てる
  ary.push(line)
}
fp.close

p ary
