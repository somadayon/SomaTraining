indata = []
File.open("G:/マイドライブ/SomaTraning/Ruby/1-2/Data.csv") do |file|
    file.each_line do |line|
        line.slice!(-2,2)
        indata.push(line.split(","))
    end
end

outdata = {}
monthdata = {}

indata.each_with_index do |arr, i|
    next if i == 0
    month = nil
    arr.each_with_index do |num, j|
        if j == 0
            month = "#{num}"
        elsif j == 1
            if num.to_i < 10
                month << "-0#{num}"
            else
                month << "-#{num}"
            end
        elsif j >= 3
        monthdata[month] ||= Array.new(arr.size - 3 + 1, 0)
        monthdata[month][j - 3] += num.to_i
        end
    end
end
p monthdata

total = 0
p indata[0]
monthdata.each do |month, data|
    o = nil
    sum = 0
    data.each_with_index do |num, i|
        if i == 0
            o = "#{indata[0][i + 1]}: #{num}"
        elsif !indata[0][i + 1]
            o << ", sum: #{sum}"
            next
        else
            o << ", #{indata[0][i + 1]}: #{num}"
        end
        sum += num.to_i
    end
    total += sum
    outdata[month] = o
end
outdata["total"] = total

File.open("result.txt", "w") do |file|
    outdata.each do |key, data|
        file.puts "#{key} => #{data}"
        puts "#{key} => #{data}"
    end
end
