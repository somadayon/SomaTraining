# coding: utf-8
puts "string:リテラル"
str="hogeFooあいう"
p str
puts

puts "string:sprintf"
str=sprintf("%04d-%02d-%02d", 2024, 4, 30)
p str
puts

puts "string:結合"
str1="もじれつ１"
str2="もじれつ２"
str = str1 + str2
p str1
p str2
p str
puts

puts "string:分割"
str="2024-04-30"
p str
p str.split("-")             # - で分割して配列にする
p str.split("-").map(&:to_i) # 更に各要素を整数に変換
puts

puts "string:置換"
str="2024-04-30"
p str
p str.gsub("-","+")
puts

puts "string:マッチング"
str="hogeほげfoo"
print "「ほげ」を含むか : "; p str.include?("ほげ")
print "「ふー」を含むか : "; p str.include?("ふー")
puts

puts "string:ファイルパス分離"
str="/home/someuser/somedir/somefile.txt"
print "filepath: "; p str
print "basename: "; p File.basename(str)
print "extname : "; p File.extname(str)
puts

#string  : リテラル　sprintf 結合　分割　置換　マッチング　ファイルパスの分離
