#!/bin/bash

CURRENT_DIR=$(cd $(dirname $0); pwd)
PATH=$CURRENT_DIR:$PATH

GEM_HOME=$CURRENT_DIR/..
HADOOP_HOME=$HUDSON_HOME/hadoop/dist
HADOOP_CONF_DIR=$CURRENT_DIR/../conf
JRUBY_JAR_DIR=$GEM_HOME/gems/jruby-jars-1.4.0/lib/

export PATH GEM_HOME HADOOP_HOME HADOOP_CONF_DIR

#echo java -classpath $JRUBY_JAR_DIR/jruby-core-1.4.0.jar:$JRUBY_JAR_DIR/jruby-stdlib-1.4.0.jar org.jruby.Main $CURRENT_DIR/papyrus $1
java -classpath $JRUBY_JAR_DIR/jruby-core-1.4.0.jar:$JRUBY_JAR_DIR/jruby-stdlib-1.4.0.jar org.jruby.Main $CURRENT_DIR/papyrus $1
