def read_file(file_path)
    ary = []
    f=open(file_path)
    f.each{|line|
        line.chomp! # 末尾の改行を捨てる
        ary.push(line.split)
    }
    return ary
end

file_path= "Data.txt"
indata=read_file(file_path)
outdata={} #{year-month,total=>sort,sum=>value}

indata.each{|ary|
    str=ary[0].split("-") #str=[year,month,day]
    date=sprintf("%04d-%02d",str[0],str[1])
    outdata[date]||={}
    
    sort=ary[1]
    outdata[date][sort]||=0
    
    value=ary[2].to_i
    outdata[date][sort]+=value
}

outdata["total"]={}
outdata.each{|date,data|
    next if date=="total"
    data.each{|sort,value|
        outdata["total"][sort]||=0
        outdata["total"][sort]+=value
    }
    outdata[date]["sum"]||=0
}

outdata["total"]["sum"]=0
outdata.each{|date,data|
    next if date=="total"
    data.each{|sort,value|
        outdata[date]["sum"]+=value if sort!="sum"
    }
    outdata["total"]["sum"]+=outdata[date]["sum"]
}

file=open("result.txt","w")    # ひらく
outdata.each{|date,data|
    file.printf("%07s ",date)
    data.each{|sort,value|
        file.printf("%s=%d ",sort,value)
    }
    file.print"\n"
}
file.close                     # 閉じる
p `cat result.txt` # 中身を表示
