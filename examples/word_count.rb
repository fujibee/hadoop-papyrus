use 'WordCount'

data 'apache log on test2' do
  from 'wc/inputs'
  to 'wc/outputs'

  count_uniq
  total :bytes, :words, :lines
end
