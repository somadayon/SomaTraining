filepath = "kinmu_ando2024_08Aug.txt"
workingtime = 0

name = filepath.match(/_(\w+)\d{4}/)[1] #name="ando"
year = filepath[-14,4]
month = filepath[-9,2]

file=open(filepath)
file.each{|line|
    line.chomp!
    next if line[0]=='#'||line.strip.empty?
    ary=line.split
    t=ary[1].split(":") #出勤時間
    t0=t[0].to_i*60+t[1].to_i #分に直す
    t=ary[2].split(":") #退勤時間
    t1=t[0].to_i*60+t[1].to_i #分に直す
    wrk=t1-t0
    wrk-=60 if wrk>6 * 60 #休憩時間
    workingtime+=wrk
}
puts "#{name}  #{year}-#{month}  #{workingtime/60}h #{workingtime%60}min"