# 差
def add(a, b)
    [a[0] + b[0], a[1] + b[1], a[2] + b[2]]
end

# 差
def sub(a, b)
    [a[0] - b[0], a[1] - b[1], a[2] - b[2]]
end

# スカラ倍
def mul(c, a)
    [c * a[0], c * a[1], c * a[2]]
end

# 長さ
def len(a)
    Math.sqrt(a[0]**2 + a[1]**2 + a[2]**2)
end

# 正規化
def nrm(a)
    mul(1.0 / len(a), a)
end

# 外積
def crs(a, b)
[
    a[1] * b[2] - a[2] * b[1],
    a[2] * b[0] - a[0] * b[2],
    a[0] * b[1] - a[1] * b[0]
]
end

# ソート
def srt(data)
    data["f"].sort_by! {|arr| arr[0]}
end

# 平均
def ave(data)
    out = []
    data.each{|vec|
        out = add(vec, out)
    }
    nrm(out)
end

# 法線を計算する関数
def cal_nrm(data)
    new_faces = []
    nrms = {}
    data["f"].each_with_index{|faces, i|
        v = [data["v"][faces[0]], data["v"][faces[1]], data["v"][faces[2]]]
        normal = nrm(crs(sub(v[1], v[0]), sub(v[2], v[0])))
        v.each_with_index{|vertex, j|
            nrms[vertex] ||= []
            nrms[vertex].push(normal)
        }
    }

    vn = {}
    nrms.each{|vertex, normal|
        vn[vertex] ||= []    
        vn[vertex] = ave(normal)
    }
    nrms = vn

    data["f"].each_with_index{|faces, i|
        new_faces[i] = "f"
        faces.each_with_index{|face, j|
            face.each_with_index{|vertex, k|
                n = nrms(vertex)
                data["n"].push(n) 
                new_faces[i] += " #{v[0]}//#{n}"
            } 
        }
    }

    data["f"] = new_faces
end

# OBJファイルを読み込む関数
def load_obj(filepath, data)
    fp = open(filepath)
    fp.each{|line|
        line.chomp!
        d = line.split()
        if d[0] == "v"
            data[d[0]].push(d[1, 3].map(&:to_f))
        elsif d[0] == "f"
            data[d[0]].push(d[1, 3].map{|v| v.to_i - 1 })
        end
    }
end

# 新しいOBJファイルを作成する関数
def write_obj(filepath, data)
    fp = open(filepath, "w")
    data["v"].each{|v| fp.puts "v #{v[0]} #{v[1]} #{v[2]}"}
    data["n"].each{|n| fp.puts "vn #{n[0]} #{n[1]} #{n[2]}"}
    data["f"].each{|f| fp.puts "f #{f[1]}//#{f[0]} #{f[2]}//#{f[0]} #{f[3]}//#{f[0]}"}
end

data = {"v" => [], "n" => [], "f" => []}

# メイン処理
load_obj('buy.obj', data)
srt(data)
cal_nrm(data)
write_obj('bunny.obj', data)