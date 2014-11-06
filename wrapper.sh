#!/bin/sh

if [ $# -ne 3 ]; then
	echo "Usage: $(basename $0) iface host udp-dstport" >&2
	exit 1
fi

IFACE=$1; shift
HOST=$1;  shift
PORT=$1;  shift

echo -n "Setting up QoS w/ iptables & tc (via sudo)..."
sudo ./lowpriudp.sh "$IFACE" "$PORT"
echo "done."

echo -n "Press return when you have run 'iperf -s -u $PORT' on $HOST..."
read BLARGH

echo "Starting UDP flood to $HOST:$PORT via $IFACE."
./lowpriudp.sh "$IFACE" "$PORT"
