use 'WordCount'

data 'word conut example' do
  from 'wc/inputs'
  to 'wc/outputs'

  count_uniq
  total :bytes, :words, :lines
end
