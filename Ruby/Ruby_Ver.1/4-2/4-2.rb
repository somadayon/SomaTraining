include Math

outdata = []
for i in 0..20 do
    x = (i * 9).to_f / 180.to_f
    data = [x, 90 * cos(x * PI - PI) + 90, 180 * (1 / (1 + exp(10 - i).to_f)).to_f]
    outdata.push(data)
end


File.open("data.csv", "w") do |f|
    outdata.each do |data|
        f.puts "#{data[0]}, #{data[1]}, #{data[2]}"
        puts "#{data[0]}, #{data[1]}, #{data[2]}"
    end
end

File.open("command.txt", "w") do |f|
    f.puts("set datafile separator ','")
    file_path = "C:/Users/somad/Downloads/code/training/ruby/4-2/data.csv"
    title = "LinearCurve"

    f.puts("set term svg")
    f.puts("set output 'C:/Users/somad/Downloads/code/training/ruby/4-2/#{title}.svg'")
    f.puts("set title '#{title}'")
    # f.puts("set xlabel 'date(day)'")
    f.puts("set ylabel 'Range[deg]'")
    f.puts("set size ratio 0.5")
    f.puts("set grid")

    f.puts("plot '#{file_path}' using 1:2 axis x1y1 with lines lt 1 title 'cos', \\")
    f.puts("     '#{file_path}' using 1:3 axis x1y1 with lines lt 2 title 'sig', \\")
end

system('gnuplot command.txt')