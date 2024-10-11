include Math

outdata = []
20.times{|i|
    x = i/19.0
    data = [x,90*cos(x*PI-PI)+90,180*(1/(1+exp(9.5-i).to_f))]
    outdata.push(data)
}


file=open("data.txt","w")
outdata.each{|data|
    file.puts "#{data[0]} #{data[1]} #{data[2]}"
    puts "#{data[0]} #{data[1]}"
}
file.close

f=open("command.txt","w")
filepath = "data.txt"
title = "Curve"
f.puts("set term svg enhanced background rgb 'white'")
f.puts("set output '#{title}.svg'")
f.puts("set title '#{title}'")
f.puts("set ylabel 'Range[deg]'")
f.puts("set size ratio #{9.0/16}")
f.puts("set grid")
f.puts("plot '#{filepath}' using 1:2 axis x1y1 with lp lt 1 title 'cos', \\")
f.puts("     '#{filepath}' using 1:3 axis x1y1 with lp lt 2 title 'sig'")
f.close

output = `gnuplot command.txt`
puts output