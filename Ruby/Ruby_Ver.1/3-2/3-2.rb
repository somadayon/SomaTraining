file_path = "C:/Users/somad/Downloads/code/training/ruby/3-2/kinmu_ando2024_08Aug.txt"

working_time = 0
File.open(file_path) do |file|
    name = file_path.match(/_(\w+)\d{4}/)[1]
    year = file_path.slice(-14,4)
    month = file_path.slice(-9,2)
    file.each_line do |line|
        line.chomp!
        next if line[0] == '#'
        pre_time = line.slice(6,5)
        post_time = line.slice(12,5)
        next if pre_time.nil? || post_time.nil?
        pre = pre_time.split(":")
        pos = post_time.split(":")
        if pos[1] > pre[1]
            wrk = (pos[0].to_i - pre[0].to_i) * 60 + (pos[1].to_i - pre[1].to_i)
        else
            wrk = (pos[0].to_i - pre[0].to_i - 1) * 60 + (pos[1].to_i - pre[1].to_i + 60)
        end
        if wrk > 8 * 60
            wrk -= 60
        elsif wrk > 6 * 60
            wrk -= 45
        end
        working_time += wrk
    end
    puts "#{name}  #{year}-#{month}  #{working_time / 60}h #{working_time % 60}min"
end