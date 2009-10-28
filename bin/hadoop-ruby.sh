HADOOP=$HADOOP_HOME/bin/hadoop 
LIB_DIR=lib

for x in `ls $LIB_DIR`; do
  DSL_FILES=$LIB_DIR/$x,$DSL_FILES
done
DSL_FILES=$DSL_FILES$1

echo runnig $1...
$HADOOP jar lib/java/hadoop-ruby.jar org.apache.hadoop.ruby.JRubyJobRunner -libjars lib/java/jruby-complete-*.jar -files $DSL_FILES $1 $2 $3
