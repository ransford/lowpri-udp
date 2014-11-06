#!/bin/sh

if [ $# -ne 2 ]; then
	echo "Usage: $(basename $0) server port" >&2
	exit 1
fi

HOST=$1; shift
PORT=$1; shift

# send 100 Mbit/s to remote host for 5 seconds
iperf -c "$HOST" -p "$PORT" -b 100M -t 5
