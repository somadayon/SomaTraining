def pp(data)
    data.each { |arr| p arr }
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

# 平均
def ave(data)
    out = [0, 0, 0]
    data.each{ |vec| out = add(vec, out) }
    nrm(out)
end

# 面の法線を計算する関数
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

# ゼロベクトルかどうかの判定
def is_zero_vec?(vec)
    vec.all? { |val| val == 0.0 }
end

# 法線ベクトルの向きを確認
def is_nrm_vec?(face, nrm, cnt)
    dot(ave(face) - cnt, nrm) > 0
end

# 面の法線を追加する関数
def add_face_nrm(data)
    cnt = ave(data["v"])

    # 法線データの計算、入力
    n_idx = 0
    new_faces = [] # 面データ置き換え用
    data["f"].each{|face|
        v = [data["v"][face[0]], data["v"][face[1]], data["v"][face[2]]]
        nrm = nrm(crs(sub(v[0], v[1]), sub(v[1], v[2])))
        data["n"][n_idx] = nrm
        # 各頂点に対応する法線インデックスを設定
        new_face = {}
        face.each do |v_idx|
            new_face[v_idx] = n_idx
        end
        new_faces.push(new_face)
        n_idx += 1
    }
    data["f"] = new_faces # 面データの置き換え
end

# PLYファイルを読み込む関数
def load_ply(filepath, data)
    fp = open(filepath)
    sign = 0
    fp.each do |line|
        line.chomp! # 改行削除

        # "end_header"まで処理待ち
        if line == "end_header"
            sign = 1
            next
        end
        next if sign == 0

        d = line.split
        sign = 2 if d[0] == "3"

        if sign == 1
            data["v"].push(d[0, 3].map(&:to_f))
        elsif d[0] == "3"
            data["f"].push(d[1, 3].map { |v| v.to_i })
        end
    end
end

# OBJファイルを書き込む関数
def write_obj(filepath, data)
    fp = open(filepath, "w")
    data["v"].each { |v| fp.puts "v #{v[0]} #{v[1]} #{v[2]}" }
    data["n"].each { |n| fp.puts "vn #{n[0]} #{n[1]} #{n[2]}" }
    data["f"].each do |face|
        f_line = "f"
        face.each { |v_idx, n_idx| f_line += " #{v_idx + 1}//#{n_idx + 1}" }
        fp.puts f_line
    end
end

data = { "v" => [], "n" => [], "f" => [] }

# メイン処理
load_ply('bun_zipper_res4.ply', data)
add_face_nrm(data)
write_obj('bunny.obj', data)
