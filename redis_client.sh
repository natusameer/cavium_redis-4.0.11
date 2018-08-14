#!/bin/bash
usage="$(basename "$0") [-h] [-s n] -- Program to run Redis Client.

where:
-h  show this help text
-s  set the server IP value (default: 127.0.0.1)"

#DEFAULT SERVER_IP
SERVER_IP="127.0.0.1"
while getopts ':hs:' option; do
	case "$option" in
		h) echo "$usage"
			exit
			;;
		s) SERVER_IP=$OPTARG
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
MAX=256
#MODE="DUAL_SOCK"
DIVISOR=`echo $(($(($SMT*$PHY_CPUS))*2))`

CWD=`pwd`

#Find the Processor ( Intel / ARM ) Architecture
ARCH=`uname -m`
if [ "$ARCH" == "x86_64" ]; then
	CLIENT_CORE_OFFSET=`echo $(($SMT*$PHY_CPUS))`
	MAKE="Intel"
elif [ "$ARCH" == "aarch64" ]; then
	CLIENT_CORE_OFFSET=`echo $(($SMT*$(($PHY_CPUS/2))))`
	MAKE="Saber"
fi

#For Results, In /tmp/ remove older result files if any
sudo rm -f /tmp/redis_*

#Go to Redis Folder
cd $CWD
#set -x

#Run Client
for ((j=$MIN; $j<=$MAX; j=$j<<1)); do
	echo "Redis Test with Client-Server $j instances"
	for ((i=0;$i<$j;i=$i+1)); do
		let cpu=$((${i}%${DIVISOR}))

		cmd="taskset -c $cpu ./src/redis-benchmark -h ${SERVER_IP} -p $((6379+$i)) -n 1000 -c $i --csv > /tmp/redis_${i} &"
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
