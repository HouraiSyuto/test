# frozen_string_literal: true

require "etc"
require "date"
require "optparse"


class LsCommand
  # データを取得する処理
  # パーミッション早見表定義
  PERMIMSSION = {
    0 => "---",
    1 => "--x",
    2 => "-w-",
    3 => "-wx",
    4 => "r--",
    5 => "r-x",
    6 => "rw-",
    7 => "rwx"
  }
  # lsオプションなしメソッド
  def ls
    Dir.glob("*").sort
  end

  # ls-rコマンドメソッド
  def ls_r(files)
    files.reverse!
  end

  # ls-aコマンドメソッド
  def ls_a
    Dir.glob([".*", "*"]).sort
  end

  # ls-lコマンドメソッド
  def ls_l(files)
    path = Dir.pwd
    files.map do |fn|
      stat = File.stat(path + "/" + fn)
      # ファイルの種類と許可属性
      # ファイルの種類
      directory = FileTest.directory?(path + "/" + fn)
      file = FileTest.file?(path + "/" + fn)
      if directory == true
        type = "d"
      elsif file == true
        type = "-"
      end
      # ファイルモード取得
      mode = "%o" % stat.mode

      # ファイルモードから語尾３文字を取り出し
      hex = mode.to_s
      hex = hex[2..4]
      # ファイル１〜３のパーミッション情報取得
      permission_1 = hex[-3, 1].to_i
      permission_2 = hex[-2, 1].to_i
      permission_3 = hex[-1, 1].to_i

      # ファイルの種類とパーミッションを合体
      attribute = type + PERMIMSSION[permission_1] + PERMIMSSION[permission_2] + PERMIMSSION[permission_3]

      # ハードリンク数
      link = stat.nlink.to_s.rjust(3)

      # 所有者
      uid = Etc.getpwuid(stat.uid).name.ljust(7)

      # グループ名
      group = Etc.getgrgid(stat.gid).name

      # ファイルサイズ
      size = stat.size.to_s.rjust(5)

      # タイムスタンプ
      time = stat.mtime
      str = time.strftime("%-m %e %H:%M")

      # 表示形式
      puts printf("#{attribute} #{link} #{uid}  #{group} #{size}  #{str} #{fn}")
    end
  end

  # データを表示するメソッド
  def ls_display(files)
    files.each do |fn|
      printf("%s", fn.ljust(15))
    end
    puts
  end
end

opt = OptionParser.new
ls = LsCommand.new

# コマンドラインから引数を取得する
params = {}
unless  ARGV[0] == nil
  opt.on("-a") { |v| params[:a] = v }
  opt.on("-r") { |v| params[:r] = v }
  opt.on("-l") { |v| params[:l] = v }
  opt.parse!(ARGV)
end

# lsコマンドを実施する
files = ls.ls

# 引数から呼び出すメソッドを判断する
# -aが引数にあるの場合
if params[:a]
  files = ls.ls_a
end

# -rが引数にあるの場合
if params[:r]
  ls.ls_r(files)
end

# -lが引数にあるの場合
if params[:l]
  ls.ls_l(files)
else
  ls.ls_display(files)
end
