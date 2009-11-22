BIN_DIR=`dirname "$0"`
BASE_DIR=`cd $BIN_DIR/..; pwd`

HADOOP=$HADOOP_HOME/bin/hadoop 
if [ ! -f $HADOOP ]; then
  HADOOP=$BIN_DIR/hadoop
fi
HADOOP_RUBY_LIB_DIR=$BASE_DIR/lib

for x in `ls $HADOOP_RUBY_LIB_DIR`; do
  DSL_FILES=$HADOOP_RUBY_LIB_DIR/$x,$DSL_FILES
done
DSL_FILES=$DSL_FILES$1

echo runnig $1...
$HADOOP jar lib/java/hadoop-ruby.jar org.apache.hadoop.ruby.JRubyJobRunner -libjars lib/java/jruby-complete-*.jar -files $DSL_FILES $1 $2 $3
