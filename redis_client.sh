#!/bin/bash
usage="$(basename "$0") [-h] [-s <SERVER_IP>] [-n <requests>] [-P <num requests>] -- Program to run Redis Client.

where:
-h  show this help text
-s  set the server IP value. Default: 127.0.0.1
-n  set the number of requests. Default 1000000
-P  Pipeline <numreq> requests. Default 1 (no pipeline)"

#DEFAULT SERVER_IP
SERVER_IP="127.0.0.1"
REQUESTS=1000000
NUMREQUESTS=1
while getopts ':hs:n:P:' option; do
	case "$option" in
		h) echo "$usage"
			exit
			;;
		s) SERVER_IP=$OPTARG
			;;
		n) REQUESTS=$OPTARG
			;;
		P) NUMREQUESTS=$OPTARG
			;;
		:) printf "missing argument for -%s\n" "$OPTARG" >&2
			echo "$usage" >&2
			exit 1
			;;
		\?) printf "illegal option: -%s\n" "$OPTARG" >&2
			echo "$usage" >&2
			exit 1
			;;
	esac
done
shift $((OPTIND - 1))

PHY_CPUS=`lscpu | grep ^Core | tr -s ' ' | cut -d" " -f4`; echo ${PHY_CPUS}
SMT=`lscpu | grep Thread | tr -s ' ' | cut -d" " -f4`;
MIN=64
MAX=128
DIVISOR=`echo $(($(($SMT*$PHY_CPUS))*2))`


#PING SERVER_IP. If SUCCESS, then only proceed.
ping $SERVER_IP -c 20 > /tmp/ping1
TX=`cat /tmp/ping1 | grep "packets transmitted" | awk '{print $1}'`
RX=`cat /tmp/ping1 | grep "packets transmitted" | awk '{print $4}'`
if [ $TX != $RX ]
then
	echo "Error. Not able to ping to $SERVER_IP. Please check!"
	exit 1
fi


#For Results, In /tmp/ remove older result files if any
sudo rm -f /tmp/redis_*

#Run Client
for ((j=$MIN; $j<=$MAX; j=$j<<1)); do
	echo "Redis Test with Client-Server $j instances"
	for ((i=0;$i<$j;i=$i+1)); do
		let cpu=$((${i}%${DIVISOR}))

		#cmd="taskset -c $cpu ./src/redis-benchmark -h ${SERVER_IP} -p $((6379+$i)) -n $REQUESTS -P $NUMREQUESTS -c $i --csv > /tmp/redis_${i} &"
		cmd="taskset -c $cpu ./src/redis-benchmark -h ${SERVER_IP} -p $((6379+$i)) -n $REQUESTS -P $NUMREQUESTS --csv > /tmp/redis_${i} &"
		echo $cmd
		eval $cmd
	done

	pidnum=`pidof redis-benchmark`
	for k in $pidnum; do
		wait $k
	done
	sleep 10
	bash get_results.sh results_${j}.csv
done

sleep 5
