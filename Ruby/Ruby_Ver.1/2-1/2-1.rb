def read_csv(file_path)
    indata = []
    File.open(file_path) do |file|
        file.each_line do |line|
            line.chomp! 
            indata.push(line.split(","))
        end
    end
    return indata
end

def calculate_min_max(file_path, column)
    data = read_csv(file_path)
    values = data.map { |row| row[column].to_f }
    return values.min, values.max
end

def to_gnuplot(folder_path)
    File.open("command.txt", mode = "w"){|f|
        f.puts("set datafile separator ','")
        Dir.glob("#{folder_path}/*.csv").each_with_index do |file_path, i|
            file_num = file_path.slice(-13,4).to_i * 10000
            file_num += file_path.slice(-8,4).to_i
            if (file_num % 10000) / 100 < 10
                title = "0#{(file_num % 10000) / 100}"
            else
                title = "#{(file_num % 10000) / 100}"
            end
            if file_num % 100 < 10
                title << "0#{file_num % 100}"
            else
                title << "#{file_num % 100}"    
            end    
            temp_min, temp_max = calculate_min_max(file_path, 1)
            humid_min, humid_max = calculate_min_max(file_path, 2)
            co2_min, co2_max = calculate_min_max(file_path, 3)
            
            # f.puts("stats '#{file_path}' using 2 name 'T'")
            # f.puts("stats '#{file_path}' using 3 name 'H'")
            # f.puts("stats '#{file_path}' using 4 name 'C'")

            f.puts("set term svg")
            f.puts("set output 'C:/Users/somad/Downloads/code/training/ruby/2-1/graph/#{file_num / 10000}/#{title}.svg'")
            f.puts("set title '#{title}'")
            f.puts("set xtics format '%H'")
            f.puts("set y2tics")
            f.puts("set yrange[#{[temp_min, humid_min].min - 10}:#{[temp_max, humid_max].max + 20}]")
            f.puts("set y2range[#{co2_min - 100}:#{co2_max + 100}]")
            f.puts("set xlabel 'time(Hour)'")
            f.puts("set ylabel 'Temperature (°C) / Humidity (%)'")
            f.puts("set y2label 'CO2 (ppm)'")
            f.puts("set size ratio 0.5")
            f.puts("set grid")
            f.puts("set xdata time")
            f.puts("set timefmt '%H:%M:%S'")
            f.puts("plot '#{file_path}' using 1:2 axis x1y1 with lines lt 1 title 'Temperature', " \
             "'#{file_path}' using 1:3 axis x1y1 with lines lt 2 title 'Humidity', " \
             "'#{file_path}' using 1:4 axis x1y2 with lines lt 3 title 'CO2'")
            p file_path
        end
        f.puts("q")
    }

    system('gnuplot command.txt')
end        

to_gnuplot("C:/Users/somad/Downloads/code/training/ruby/2-1/kand-T6540/kand-T6540-2020/telem/dat/kand/T6540-17965017/2020")
to_gnuplot("C:/Users/somad/Downloads/code/training/ruby/2-1/kand-T6540/kand-T6540-2021/kand-T6540-2021")