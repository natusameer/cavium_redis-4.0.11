#!/bin/bash
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


# bench.sh
# Starts 512 instances of Server.
# Starts 64 and 512 instances of Clients
# and then outputs the results.

# Server and Client with 64 Instances
./redis_server.sh -I 64 
./redis_client.sh -I 64 -n $REQUESTS -P $NUMREQUESTS -s ${SERVER_IP}

sleep 10

# Server and Client with 512 Instances
./redis_server.sh -I 512
./redis_client.sh -I 512 -n $REQUESTS -P $NUMREQUESTS -s ${SERVER_IP}

# Kill Redis Server
sudo killall redis-server

#Check Results stored in csv format


