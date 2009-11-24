#!/bin/bash
BIN_DIR=`dirname "$0"`
BASE_DIR=`cd $BIN_DIR/..; pwd`

# choose hadoop sh
HADOOP=$HADOOP_HOME/bin/hadoop 
if [ ! -f $HADOOP ]; then
  HADOOP=$BIN_DIR/hadoop
  #HADOOP_OPTS="--config $BASE_DIR/conf"
fi

# fetch jruby jar if not exist
LIB_DIR=$BASE_DIR/lib/java
JRUBY_JAR=jruby-complete-1.4.0.jar
if [ ! -f "$LIB_DIR/$JRUBY_JAR" ]; then
  wget http://jruby.kenai.com/downloads/1.4.0/jruby-complete-1.4.0.jar 
  mv $JRUBY_JAR $LIB_DIR/
fi

# construct command line
HADOOP_RUBY_LIB_DIR=$BASE_DIR/lib
for x in `ls $HADOOP_RUBY_LIB_DIR`; do
  DSL_FILES=$HADOOP_RUBY_LIB_DIR/$x,$DSL_FILES
done
DSL_FILES=$DSL_FILES$1

# execute hadoop ruby
echo runnig $1...
$HADOOP $HADOOP_OPTS jar $LIB_DIR/hadoop-ruby.jar org.apache.hadoop.ruby.JRubyJobRunner -libjars $LIB_DIR/$JRUBY_JAR -files $DSL_FILES $1 $2 $3
