require 'date'

date = Date.new(2024, 8, 5)
today = Date.today
puts "#{date.year}年#{date.month}月#{date.day}日から#{today.year}年#{today.month}月#{today.day}日までの暦日数は #{(today - date).to_i}日"