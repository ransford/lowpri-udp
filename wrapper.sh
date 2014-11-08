#!/bin/sh

if [ $# -ne 3 ]; then
	echo "Usage: $(basename $0) iface host udp-dstport" >&2
	exit 1
fi

IFACE=$1; shift
HOST=$1;  shift
PORT=$1;  shift

echo "Setting up QoS w/ iptables & tc (via sudo)..."
sudo ./lowpriudp.sh "$IFACE" "$PORT"
echo "done."

echo -n "Press return when you have run 'iperf -s -u -p $PORT' on $HOST..."
read BLARGH

echo "Starting UDP flood to $HOST:$PORT via $IFACE."
./udpflood.sh "$HOST" "$PORT"

echo "Statistics from tc:"
tc -s qdisc ls dev "$IFACE"
tc -s -p -d class show dev wlan2
