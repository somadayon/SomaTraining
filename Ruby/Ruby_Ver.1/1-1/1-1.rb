Data = [] #[year, month, day, book, taxi, kosai]
Sum = [] #[month, book, taxi, kosai]
Total = [0, 0, 0] #[book, taxi, kosai]
N = 2

for i in 1..(N * 360) do
    days = [2020 + i / 365, 1 + (i / 30 % 12), 1 + (i % 30), i, i + 1, i + 2]
    Data.push(days)
end

#p Data

for d in Data do
    if d[1] >= 10 && d[2] >= 10
        day = "#{d[0]}-#{d[1]}-#{d[2]}"
    elsif d[1] >= 10
        day = "#{d[0]}-#{d[1]}-0#{d[2]}"
    elsif d[2] >= 10
        day = "#{d[0]}-0#{d[1]}-#{d[2]}"
    else
        day = "#{d[0]}-0#{d[1]}-0#{d[2]}"
    end
    #puts "day: #{day}, book: #{d[3]}, taxi: #{d[4]}, kosai: #{d[5]}"
end    

for n in 1..N do
    for i in 1..12 do
        b = 0
        t = 0
        k = 0
        for j in 1..30 do 
            b += Data[i * j][3]
            t += Data[i * j][4]
            k += Data[i * j][5]
            month_Data = [b, t, k]
        Sum.push(month_Data)
        Total[0] += b
        Total[1] += t
        Total[2] += k
        end
    end
end


for n in 1..N do
    for i in 1..12 do
        if i < 10
            print "#{2020 + n - 1}年  #{i}月"
        else 
            print "#{2020 + n - 1}年 #{i}月"
        end
        print " book: #{Sum[i + (n - 1) * 12][0]}, taxi: #{Sum[i + (n - 1) * 12][1]}, kosai: #{Sum[i + (n - 1) * 12][2]}, "
        s = 0
        for j in 0..2 do
            s += Sum[i + (n - 1) * 12][j]
        end
        puts "Sum: #{s}"
    end
end

puts "book: #{Total[0]}, taxi: #{Total[1]}, kosai: #{Total[2]}" 
