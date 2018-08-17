#!/bin/bash

RESULT_FILE=$1
rm -f $RESULT_FILE
grep -wh "PING_INLINE" /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -wh "PING_BULK" /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -wh "SET" /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -wh "GET" /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -wh "INCR" /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -wh "LPUSH\"" /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -wh "RPUSH" /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -wh "LPOP" /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -wh "RPOP" /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -wh "SADD" /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -wh "HSET" /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -wh "SPOP" /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -wh "LPUSH " /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -wh "LRANGE_100" /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -wh "LRANGE_300" /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -wh "LRANGE_500" /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -wh "LRANGE_600" /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -wh "MSET" /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE

