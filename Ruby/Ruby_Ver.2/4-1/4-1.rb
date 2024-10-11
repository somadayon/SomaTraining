outdata=[]
20.times{|i|
    data = [i/19.0,i*180/19]
    outdata.push(data)
}

file=open("data.txt","w")
outdata.each{|data|
    file.puts "#{data[0]} #{data[1]}"
    puts "#{data[0]} #{data[1]}"
}
file.close

f=open("command.txt","w")
filepath = "data.txt"
title = "LinearCurve"
f.puts("set term svg enhanced background rgb 'white'")
f.puts("set output '#{title}.svg'")
f.puts("set title '#{title}'")
f.puts("set ylabel 'Range[deg]'")
f.puts("set size ratio #{9.0/16}")
f.puts("set grid")
f.puts("plot '#{filepath}' using 1:2 axis x1y1 with lp lt 1 title 'servo'")
f.close


output = `gnuplot command.txt`
puts output