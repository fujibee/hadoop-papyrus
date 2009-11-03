use 'LogAnalysis'

data do
  pattern /(.*) (.*) (.*) \[(.*)\] (".*") (\d*) (\d*)/
  column_name 'remote_host', PASS, 'user', 'access_date', 'request', 'status', 'bytes' # 各カラムにラベルをつける

  column :user do
    count_uniq # デフォルトのカラムの値
  end

  column :access_date do
    date = Date.new(value) # valueという変数にカラム値が入る
    select date, :range => MONTHLY # 月別に分ける
    count_uniq
  end

  column :bytes do
    to_kilobytes # / 1024
    sum
  end
end
