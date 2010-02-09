dsl 'LogAnalysis'

data 'apache log on test2' do
  from 'apachelog/inputs'
  to 'apachelog/outputs'

  # 119.63.199.8 - - [15/Nov/2009:01:18:16 +0900] "GET /ranking/game?page=31 HTTP/1.1" 200 10077 "-" "Baiduspider+(+http://www.baidu.jp/spider/)"
  # 203.83.243.81 - - [15/Nov/2009:01:18:33 +0900] "GET /dns_zones.txt HTTP/1.1" 404 294 "-" "libwww-perl/5.65"

  each_line do
    pattern /(.*) (.*) (.*) \[(.*)\] (".*") (\d*) (\d*) (.*) "(.*)"/
    column_name 'remote_host', 'pass', 'user', 'access_date', 'request', 'status', 'bytes', 'pass', 'ua'

    topic 'ua counts', :label => 'ua' do
      count_uniq column[:ua]
    end

    topic 'count bot', :label => 'bot' do
      ua = column[:ua].value
      bot = ua if ua =~ /bot/i
      count_uniq bot
    end

    topic 'ua counts group by path' do
      request = column[:request].value
      if request
        path = request.split(/\s+/)[1]
        group_by path
      end
      count_uniq column[:ua]
    end

    topic 'ua counts by daily' do
      group_date_by column[:access_date], :daily
      count_uniq column[:ua]
    end

#    topic 'total bytes' do
#      select_date column[:access_date], BY_MONTHLY
#      sum column[:bytes].to_kilobytes # / 1024
#    end
  end
end
