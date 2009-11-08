use 'LogAnalysis'

data 'apache log on test1' do
  from 'apachlog/inputs'
  to 'apachlog/outputs'

  each_line do
    pattern /(.*) (.*) (.*) \[(.*)\] (".*") (\d*) (\d*)/
    column_name 'remote_host', PASS, 'user', 'access_date', 'request', 'status', 'bytes' # 各カラムにラベルをつける

    topic 'which users?', :label => 'user' do
      count_uniq column[:user]
    end

#    topic 'access date by monthly' do
#      select_date column[:access_date], BY_MONTHLY
#      count column[:access_date]
#    end
#
#    topic 'total bytes' do
#      select_date column[:access_date], BY_MONTHLY
#      sum column[:bytes].to_kilobytes # / 1024
#    end
  end
end
