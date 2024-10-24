def pp(data)
    data.each{|arr|
        p arr
    }
end

# ベクトル和
def add(a, b)
    [a[0] + b[0], a[1] + b[1], a[2] + b[2]]
end

# ベクトル差
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
    length = len(a)
    return [0.0, 0.0, 0.0] if length == 0.0 # ゼロベクトルの場合
    mul(1.0 / length, a)
end

# 内積
def dot(a, b)
    a[0] * b[0] + a[1] * b[1] + a[2] * b[2]
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
    out = [0, 0, 0]
    data.each{|vec| 
        out = mul(-1, out) if dot(vec, out) < 0
        out = add(vec, out) 
    }
    nrm(out)
end

def is_zero_vec?(vec)
    # ベクトルのすべての要素が0.0の場合のみ1を返す
    vec.all? { |val| val == 0.0 } ? true : false
end
  
# 法線を計算する関数
def cal_nrm(v)
    candidates = [
    crs(sub(v[0], v[1]), sub(v[0], v[2])),
    crs(sub(v[0], v[1]), sub(v[1], v[2])),
    crs(sub(v[0], v[2]), sub(v[2], v[1]))
  ]

  # 候補の中で最初にゼロベクトルでないものを法線に採用
  candidates.each do |candidate|
    return candidate unless is_zero_vec?(candidate)
  end

  [0.0, 0.0, 0.0] # 全ての候補がゼロベクトルの場合
end

# 法線を追加する関数
def add_nrm(data)

    # 頂点毎の法線データの算出
    nrms = {} # 頂点毎の法線データ
    data["f"].each{|face|
        v = [data["v"][face[0]], data["v"][face[1]], data["v"][face[2]]]
        normal = cal_nrm(v)

        next if is_zero_vec?(normal) 
        
        # 法線を正規化
        normal = nrm(normal)

        # 各頂点に法線を追加
        face.each{|v_index|
            nrms[v_index] ||= []
            nrms[v_index].push(normal) # 頂点毎の法線データ
        }
    }

    # 頂点毎の法線データ平均の算出
    vn = {} # 頂点毎の法線データ平均
    nrms.each{|v_index, normals|
        vn[v_index] ||= []
        vn[v_index] = ave(normals)
    }

    # 法線データの入力
    n_index = 0
    vn.each{|v_index, normal|
        data["n"][n_index] = normal
        nrms[v_index] = n_index
        n_index += 1
    }

    # 面データの入力
    new_faces = [] # 面データ置き換え用
    data["f"].each{|face|
        new_face = {}
        face.each{|v_index|
            new_face[v_index] = nrms[v_index]
        }
        new_faces.push(new_face)
    }
    data["f"] = new_faces # 面データの置き換え
end

# PLYファイルを読み込む関数
def load_ply(filepath, data)
    fp = open(filepath)
    sign = 0
    fp.each{|line|
        line.chomp! # 改行削除

        # "end_header"まで処理待ち
        if line == "end_header"
            sign = 1 
            next
        end
        next if sign == 0

        d = line.split()
        sign = 2 if d[0] == "3"

        if sign == 1
            p d[0,3]
            data["v"].push(d[0, 3].map(&:to_f))
        elsif d[0] == "3"
            data["f"].push(d[1, 3].map{|v| v.to_i })
        end
    }
end

# OBJファイルを書き込む関数
def write_obj(filepath, data)
    fp = open(filepath, "w")
    data["v"].each{|v| fp.puts "v #{v[0]} #{v[1]} #{v[2]}"}
    data["n"].each{|n| fp.puts "vn #{n[0]} #{n[1]} #{n[2]}"}
    data["f"].each{|face|
        f_line = "f"
        face.each { |v_index, n_index| f_line += " #{v_index + 1}//#{n_index + 1}" }
        fp.puts f_line
    }
end

data = {"v" => [], "n" => [], "f" => []}

# メイン処理
load_ply('bun_zipper_res4.ply', data)
srt(data)
add_nrm(data)
write_obj('bunny.obj', data)