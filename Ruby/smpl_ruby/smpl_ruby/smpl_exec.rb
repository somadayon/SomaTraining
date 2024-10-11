# coding: utf-8
puts "外部呼び出し：shell経由でコマンドを実行する"
puts

puts "pwd を実行"
ret=`pwd`;  p ret
puts

puts "ls を実行"
ret=`ls`;  p ret
puts

puts "ls *.rb を実行してファイル名の配列を得る"
ret=`ls *.rb`.split;  p ret
puts

puts "date を実行"
ret=`date`;  p ret
puts



