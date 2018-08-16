#!/bin/bash
# bench.sh : Starts 64 and 512 instances of Clients

usage="$(basename "$0") [-h] [-n <requests>] [-P <num requests>]  -- Program to run Redis Client.

where:
-h  show this help text
-n  set the number of requests. Default 1000000
-P  Pipeline <numreq> requests. Default 1 (no pipeline)"

#DEFAULT SERVER_IP
SERVER_IP="127.0.0.1"
REQUESTS=1000000
NUMREQUESTS=1
while getopts ':hs:n:P:I:' option; do
	case "$option" in
		h) echo "$usage"
			exit
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

rm -f stdout.log

######### Server and Client with 64 Instances #############
NUMINSTANCES=64
./redis_server.sh -I ${NUMINSTANCES}
./redis_client.sh -I ${NUMINSTANCES} -n $REQUESTS -P $NUMREQUESTS -s ${SERVER_IP} -S 0

#Result Summary 
#Create Header
cut -d ',' -f1 results_${NUMINSTANCES}.csv | cut -d ' ' -f1 > op
printf "%14s\t" > summary.out
while read line; do printf "%12s" $line; done < op >> summary.out;
echo "" >> summary.out

cut -d ',' -f2 results_${NUMINSTANCES}.csv | cut -d ' ' -f1 > rps
printf "%4s instances\t" $NUMINSTANCES >> summary.out
while read line; do printf "%12s" $line; done < rps >> summary.out;
echo "" >> summary.out

echo 'TESTS, Total Requests/Sec, Latency_50%, Latency_95%, Latency_99%, Latency_99.95%, Latency_99.99%' | cat - results_${NUMINSTANCES}.csv > temp && mv temp results_${NUMINSTANCES}.csv

#Sleep for 10 seconds between 2 tests
sleep 10


######### Server and Client with 512 Instances #############
NUMINSTANCES=512
./redis_server.sh -I ${NUMINSTANCES}
./redis_client.sh -I ${NUMINSTANCES} -n $REQUESTS -P $NUMREQUESTS -s ${SERVER_IP} -S 0

#Result Summary 
cut -d ',' -f2 results_${NUMINSTANCES}.csv | cut -d ' ' -f1 > rps
printf "%4s instances\t" $NUMINSTANCES >> summary.out
while read line; do printf "%12s" $line; done < rps >> summary.out;
echo "" >> summary.out

# Kill Redis Server
sudo killall redis-server >> stdout.log

echo 'TESTS, Total Requests/Sec, Latency_50%, Latency_95%, Latency_99%, Latency_99.95%, Latency_99.99%' | cat - results_${NUMINSTANCES}.csv > temp && mv temp results_${NUMINSTANCES}.csv

######### Check Results stored in csv format #############
echo "Result Summary"
echo -e "--------------\n"
cat summary.out

echo -ne "\n For full results see:\n";
ls results_*.csv 

#Remove Temporary Files
rm -f op rps
