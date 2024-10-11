indata=[["2005-02-05","book",200],
        ["2005-02-05","taxi",5000],
        ["2005-02-05","taxi",3000],
        ["2005-02-06","kosai",60000],
        ["2005-03-05","taxi",8000],
        ["2007-02-05","kosai",90000]] #[year-month-day,sort,value]
          
outdata={} #{year-month,total=>sort,sum=>value}

indata.each{|ary|
    str=ary[0].split("-") #str=[year,month,day]
    date=sprintf("%04d-%02d", str[0], str[1])
    outdata[date]||={}
    
    sort=ary[1]
    outdata[date][sort]||=0
    
    value=ary[2]
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

outdata.each{|date,data|
    printf("%07s ",date)
    data.each{|sort,value|
        printf("%s=%d ",sort,value)
    }
    print"\n"
}