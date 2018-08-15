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

PHY_CPUS=`lscpu | grep ^Core | tr -s ' ' | cut -d" " -f4`; echo ${PHY_CPUS}
SMT=`lscpu | grep Thread | tr -s ' ' | cut -d" " -f4`;

#MODE="DUAL_SOCK"
DIVISOR=`echo $(($(($SMT*$PHY_CPUS))*2))`

CWD=`pwd`

#Find the Processor ( Intel / ARM ) Architecture
ARCH=`uname -m`
if [ "$ARCH" == "x86_64" ];then
	CLIENT_CORE_OFFSET=`echo $(($SMT*$PHY_CPUS))`
	MAKE="Intel"
elif [ "$ARCH" == "aarch64" ]; then
	CLIENT_CORE_OFFSET=`echo $(($SMT*$(($PHY_CPUS/2))))`
	MAKE="Saber"
fi

#For Results, In /tmp/ remove older result files if any
sudo rm -f /tmp/[0-1]*
sudo rm -f /tmp/redis_*
sudo rm -f /tmp/result_*

#Go to Redis Folder
cd $CWD
if pgrep redis-server; then
	sudo killall redis-server;
	sleep 30
fi

#Run Server
for ((i=0;$i<$NUMINSTANCES;i=$i+1));
do
	let cpu=$((${i}%${DIVISOR}))

	cmd="taskset -c $cpu ./src/redis-server --port $((6379+$i)) --bind ${SERVER_IP} &"
	echo $cmd
	eval $cmd
done

sleep 5
