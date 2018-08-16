#!/bin/bash
usage="$(basename "$0") [-h] [-I <Client Instances>] -- Program to run Redis Client.

where:
-h  show this help text
-I  Set number of Client instances. Default 512"

#DEFAULT SERVER_IP
SERVER_IP="0.0.0.0"
NUMINSTANCES=512
while getopts ':hI:' option; do
	case "$option" in
		h) echo "$usage"
			exit
			;;
		I) NUMINSTANCES=$OPTARG
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

#For Results, In /tmp/ remove older result files if any
sudo rm -f /tmp/redis_*

#Go to Redis Folder
echo "Starting $NUMINSTANCES Redis-Server instances"
if pgrep -c redis-server >> stdout.log; then
	sudo killall redis-server >> stdout.log;
	sleep 30
fi

#Run Server
for ((i=0;$i<$NUMINSTANCES;i=$i+1));
do
	let cpu=$((${i}%${DIVISOR}))

	cmd="taskset -c $cpu ./src/redis-server --port $((6379+$i)) --bind ${SERVER_IP} &"
	eval $cmd >> stdout.log
done
sleep 5
echo "$NUMINSTANCES Servers Ready"

