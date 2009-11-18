use 'LogAnalysis'

data 'v3 log' do
  each_line do
    separate(/,/)
    column_name 'pass', 'ua'

    topic 'user agent' do
      count_uniq column[:ua]
    end
  end
end
