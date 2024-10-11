
outdata = []
for i in 0..20 do
    data = [(i * 9).to_f / 180.to_f, i * 9]
    outdata.push(data)
end

File.open("data.csv", "w") do |f|
    outdata.each do |data|
        f.puts "#{data[0]}, #{data[1]}"
        puts "#{data[0]}, #{data[1]}"
    end
end

File.open("command.txt", "w") do |f|
    f.puts("set datafile separator ','")
    file_path = "C:/Users/somad/Downloads/code/training/ruby/4-1/data.csv"
    title = "LinearCurve"

    f.puts("set term svg")
    f.puts("set output 'C:/Users/somad/Downloads/code/training/ruby/4-1/#{title}.svg'")
    f.puts("set title '#{title}'")
    # f.puts("set xlabel 'date(day)'")
    f.puts("set ylabel 'Range[deg]'")
    f.puts("set size ratio 0.5")
    f.puts("set grid")

    f.puts("plot '#{file_path}' using 1:2 axis x1y1 with lines lt 1 title 'servo', \\")
    #f.puts("q")
end

system('gnuplot command.txt')