#!/bin/bash
usage="$(basename "$0") [-h] [-s <SERVER_IP>] [-n <requests>] [-P <num requests>] [-I <Client Instances>] [-S < Output Summary >] -- Program to run Redis Client.

where:
-h  show this help text
-s  set the server IP value. Default: 127.0.0.1
-n  set the number of requests. Default 1000000
-P  Pipeline <numreq> requests. Default 1 (no pipeline)
-I  Set number of Client instances. Default 64
-S  Output Result Summary to STDOUT. Default 1"

#DEFAULT SERVER_IP
SERVER_IP="127.0.0.1"
REQUESTS=1000000
NUMREQUESTS=1
NUMINSTANCES=64
SUMMARY=1
while getopts ':hs:n:P:I:S:' option; do
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
		I) NUMINSTANCES=$OPTARG
			;;
		S) SUMMARY=$OPTARG
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

PHY_CPUS=`lscpu | grep ^Core | tr -s ' ' | cut -d" " -f4`;
SMT=`lscpu | grep Thread | tr -s ' ' | cut -d" " -f4`;
DIVISOR=`echo $(($(($SMT*$PHY_CPUS))*2))`


#PING SERVER_IP. If SUCCESS, then only proceed.
ping $SERVER_IP -c 6 > /tmp/ping1
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
echo -e "\nStarting Redis Benchmark Test with $NUMINSTANCES instances\n"
for ((i=0;$i<$NUMINSTANCES;i=$i+1)); do
	let cpu=$((${i}%${DIVISOR}))

	cmd="taskset -c $cpu ./src/redis-benchmark -h ${SERVER_IP} -p $((6379+$i)) -n $REQUESTS -P $NUMREQUESTS --csv > /tmp/redis_${i} & "
#	echo $cmd
	eval $cmd
done

pidnum=`pidof redis-benchmark`
for k in $pidnum; do
	wait $k
done
sleep 10
echo -e "Completed.... Computing Results!\n"
bash get_results.sh results_${NUMINSTANCES}.csv

#Backup Detailed log files for each instance
today=`date +%Y-%m-%d.%H:%M:%S`
mkdir log_${NUMINSTANCES}instances_${today}
mv /tmp/redis_* log_${NUMINSTANCES}instances_${today}/


if [ "$SUMMARY" -eq 1 ]; then
	#Generate SUMMARY Header
	cut -d ',' -f1 results_${NUMINSTANCES}.csv | cut -d ' ' -f1 > op
	printf "%14s\t" > summary.out
	while read line; do printf "%12s" $line; done < op >> summary.out;
	echo "" >> summary.out

	cut -d ',' -f2 results_${NUMINSTANCES}.csv | cut -d ' ' -f1 > rps
	printf "%4s instances\t" $NUMINSTANCES >> summary.out
	while read line; do printf "%12s" $line; done < rps >> summary.out;
	echo "" >> summary.out

	echo 'TESTS, Total Requests/Sec, Latency_50%, Latency_95%, Latency_99%, Latency_99.95%, Latency_99.99%' | cat - results_${NUMINSTANCES}.csv > temp && mv temp results_${NUMINSTANCES}.csv

	echo "Result Summary"
	echo -e "--------------\n"
	cat summary.out

	echo -ne "\n For full results see results_{$NUMINSTANCES}.csv, log_{$NUMINSTANCES}instances_${today}/"
fi

sleep 5
