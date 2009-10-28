# Apache log analysis
#
# example target data:
#   127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326
#   127.0.0.1 - frank2 [10/Oct/2000:13:55:36 -0700] "GET /apache_pb2.gif HTTP/1.0" 200 2326
#   127.0.0.1 - frank2 [10/Oct/2000:13:55:36 -0700] "GET /apache_pb3.gif HTTP/1.0" 404 2326

use 'LogAnalysis'

data.pattern /(.*) (.*) (.*) (\[.*\]) (".*") (\d*) (\d*)/
column[2].count_uniq
column[3].count_uniq
column[4].count_uniq
column[5].count_uniq
column[6].sum
