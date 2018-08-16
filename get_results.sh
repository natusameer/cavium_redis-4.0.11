#!/bin/bash

RESULT_FILE=$1

rm -f $RESULT_FILE
grep -h PING_INLINE /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -h PING_BULK /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -h SET /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -h GET /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -h INCR  /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -h LPUSH /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -h RPUSH /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -h LPOP /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -h RPOP /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -h SADD /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -h HSET /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -h SPOP /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -h LPUSH /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -h LRANGE_100 /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -h LRANGE_300 /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -h LRANGE_500 /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -h LRANGE_600 /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE
grep -h MSET /tmp/redis_* | ./compute_results.pl >> $RESULT_FILE

