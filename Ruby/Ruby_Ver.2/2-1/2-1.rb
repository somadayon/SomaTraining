def plot(folderpath)
    file=open("command.txt","w")
    str= `ls #{folderpath}`
    filelist=str.split("\n")
    year=folderpath[-4,4]
    filelist.each{|filepath|
        month=filepath[0,2]
        day=filepath[2,2]
        date= "#{year}-#{month}-#{day}"
        file.puts("reset")
        file.puts("set term svg enhanced background rgb 'white'")
        file.puts("set datafile separator ','")
        # file.puts("set size 1920,1080")
        file.puts("set title '#{date}'")
        file.puts("set output 'graph/#{date}.svg'")
        file.puts("set xtics format '%H:%M'")
        file.puts("set ytics ('0   0'0,'10  20'20,'20  40'40,'30  60'60,'40  80'80,'50 100'100)")
        file.puts("set y2tics (0,200,400,600,800,1000)")
        file.puts("set yrange [0:100]")
        file.puts("set y2range [0:1000]")
        file.puts("set xlabel 'time(Hour)'")
        file.puts("set ylabel 'Temperature (°C) / Humidity (%)'")
        file.puts("set y2label 'CO2 (ppm)'")
        file.puts("set size ratio #{9.0/16}")
        file.puts("set xdata time")
        file.puts("set timefmt '%H:%M:%S'")
        file.puts("set grid")
        file.puts("plot '#{folderpath}/#{filepath}' using 1:($2*2) axis x1y1 with lines lt 1 title 'Temperature', " \
                       "'#{folderpath}/#{filepath}' using 1:($3) axis x1y1 with lines lt 2 title 'Humidity', " \
                       "'#{folderpath}/#{filepath}' using 1:($4) axis x1y2 with lines lt 3 title 'CO2'")
    }
    file.close

    output = `gnuplot command.txt`
    puts output
end        

plot("kand-T6540/kand-T6540-2020/telem/dat/kand/T6540-17965017/2020")
plot("kand-T6540/kand-T6540-2021/kand-T6540-2021")