def plot(folderpathes)
    file=open("data.txt","w")    
    file.puts("date    temp_ave temp_max temp_min temp_med co2_ave  co2_max  co2_min  co2_med  hum_ave  hum_max  hum_min  hum_med")
    folderpathes.each{|folderpath|
        indata = {} #月毎 input
        outdata = {} #{month / day / [temp(0), hum(1), co2(2)]  / {ave, max, min, med}}

        year=folderpath[-4,4]
        str= `ls #{folderpath}`
        filelist=str.split("\n")
        year=folderpath[-4,4]
        filelist.each{|filepath|
            month=filepath[0,2]
            day=filepath[2,2]
            date= "#{year}-#{month}"
            indata[date]||=[] #列毎かつ月毎に格納
            
            f=open("#{folderpath}/#{filepath}")
            f.each{|line|
                line.chomp! # 末尾の改行を捨てる
                ary=line.split(",")
                ary.delete_at(0)
                ary.each_with_index{|val,i|
                    next if val.to_i<=0 && i!=0
                    indata[date][i]||=[]
                    indata[date][i].push(val)
                }
            }
        }

        indata.each{|date, data|
            outdata[date]||={}
            data.each_with_index{|ary, i|
                ary.map!(&:to_i)
                ary.sort!

                ave=ary.sum/ary.size
                max=ary[-1]
                min=ary[0]
                if ary.size.odd?
                    med = ary[ary.size/2]
                else
                    med = (ary[ary.size/2-1]+ary[ary.size/2])/2
                end

                outdata[date][i]||={"ave"=>ave,"max"=>max,"min"=>min,"med"=>med}
                puts "#{date},#{i}=>#{outdata[date][i]}"
            }
        }

        outdata.each{|date,data|
            file.print(date)
            data.each{|k,val|
                file.printf(" %8d %8d %8d %8d", val['ave'], val['max'], val['min'], val['med'])
            }
            file.print "\n"
        }
    }
    file.close
end

folderpathes=["kand-T6540/kand-T6540-2020/telem/dat/kand/T6540-17965017/2020",
              "kand-T6540/kand-T6540-2021/kand-T6540-2021"]
plot(folderpathes)