folder_pathes = []
folder_pathes.push("C:/Users/somad/Downloads/code/training/ruby/2-1/kand-T6540/kand-T6540-2020/telem/dat/kand/T6540-17965017/2020")
folder_pathes.push("C:/Users/somad/Downloads/code/training/ruby/2-2/kand-T6540/kand-T6540-2021/kand-T6540-2021")

def to_gnuplot(folder_pathes)
    indata = {} #月毎 input
    outdata = {} #{month / day / [temp(0), hum(1), co2(2)]  / {ave, max, min, med}}

    folder_pathes.each do |folder_path|
        folder_num = folder_path.slice(-4,4).to_i
        year = "%04d" % folder_num
        Dir.glob("#{folder_path}/*.csv").each_with_index do |file_path, i|
            file_num = file_path.slice(-13,4).to_i * 10000
            file_num += file_path.slice(-8,4).to_i
            month = "#{year}%02d" % ((file_num % 10000) / 100)
            day = "%02d" % (file_num % 100)
            d = []
            indata[month] ||= {}
            indata[month][day] = []
            File.open("#{file_path}") do |file|
                file.each_line do |line|
                    line.chomp!
                    d = line.split(",")
                    d.each_with_index do |num, i|
                        next if i == 0
                        indata[month][day][i - 1] ||= []
                        indata[month][day][i - 1].push(num)
                    end
                end
            end
        end
    end

    indata.each do |month, array|
        outdata[month] ||= {}
        array.each do |day, data|
            outdata[month][day] ||= {}
            data.each_with_index do |arr, i|
                arr.map!(&:to_i)
                arr.sort!

                ave = arr.sum / arr.size
                max = arr.last
                min = arr.first
                if arr.size.odd?
                    med = arr[arr.size / 2]
                else
                    med = (arr[arr.size / 2 - 1] + arr[arr.size / 2]) / 2
                end

                outdata[month][day][i] ||= {"ave" => ave, "max" => max, "min" => min, "med" => med}
                #puts "#{month}:#{day} , i = #{i} ... #{outdata[month][day][i]}"
            end
        end
    end

    outdata.each do |month, days|
        p "#{month}.csv"
        File.open("C:/Users/somad/Downloads/code/training/ruby/2-2/data/#{month}.csv", mode = "w"){|f|
            days.each do |day, data|
                f.print("#{day}")
                print("#{day}")
                data.each do |_, values|
                    f.print(", #{values['ave']}, #{values['max']}, #{values['min']}, #{values['med']}")
                    print(", #{values['ave']}, #{values['max']}, #{values['min']}, #{values['med']}")
                end
                f.print "\n"
                print "\n"
            end
        }
    end

    File.open("command.txt", mode = "w"){|f|
        f.puts("set datafile separator ','")
        Dir.glob("C:/Users/somad/Downloads/code/training/ruby/2-2/data/*.csv").each_with_index do |file_path, i|
            year = file_path.slice(-10,4)
            month = file_path.slice(-6,2)
            p year + month
            title = "#{month}"    

            f.puts("set term svg")
            f.puts("set output 'C:/Users/somad/Downloads/code/training/ruby/2-2/graph/#{year}/#{month}.svg'")
            f.puts("set title '#{title}'")
            #f.puts("set xtics format '%d'")
            f.puts("set xtics 1")
            f.puts("set y2tics")
            # f.puts("set yrange[#{[temp_min, humid_min].min - 10}:#{[temp_max, humid_max].max + 20}]")
            # f.puts("set y2range[#{co2_min - 100}:#{co2_max + 100}]")
            f.puts("set xlabel 'date(day)'")
            f.puts("set ylabel 'Temperature (°C) / Humidity (%)'")
            f.puts("set y2label 'CO2 (ppm)'")
            f.puts("set size ratio 0.5")
            f.puts("set grid")
            # f.puts("set xdata time")
            # f.puts("set timefmt '%d'")
            f.puts("plot '#{file_path}' using 1:2 axis x1y1 with lines lt 1 title 'Temperature_ave', \\")
            f.puts("     '#{file_path}' using 1:3 axis x1y1 with lines lt 2 title 'Temperature_max', \\")
            f.puts("     '#{file_path}' using 1:4 axis x1y1 with lines lt 3 title 'Temperature_min', \\")
            f.puts("     '#{file_path}' using 1:5 axis x1y1 with lines lt 4 title 'Temperature_med', \\")
            f.puts("     '#{file_path}' using 1:6 axis x1y1 with lines lt 5 title 'Humidity_ave', \\")
            f.puts("     '#{file_path}' using 1:7 axis x1y1 with lines lt 6 title 'Humidity_max', \\")
            f.puts("     '#{file_path}' using 1:8 axis x1y1 with lines lt 7 title 'Humidity_min', \\")
            f.puts("     '#{file_path}' using 1:9 axis x1y1 with lines lt 8 title 'Humidity_med', \\")
            f.puts("     '#{file_path}' using 1:10 axis x1y2 with lines lt 9 title 'CO2_ave', \\")
            f.puts("     '#{file_path}' using 1:11 axis x1y2 with lines lt 10 title 'CO2_max', \\")
            f.puts("     '#{file_path}' using 1:12 axis x1y2 with lines lt 11 title 'CO2_min', \\")
            f.puts("     '#{file_path}' using 1:13 axis x1y2 with lines lt 12 title 'CO2_med'")
            p file_path
        end
        f.puts("q")
    }

    system('gnuplot command.txt')
end

to_gnuplot(folder_pathes)