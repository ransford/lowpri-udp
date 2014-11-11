#!/bin/sh
#
# Assign low priority to everything $IFACE sends to a certain UDP port.
#

if [ $# -ne 2 ]; then
	echo "Usage: $(basename $0) iface udp-dstport" >&2
	exit 1
fi

IFACE=$1;   shift
UDPPORT=$1; shift

echo flushing tc...
tc qdisc del dev $IFACE root
echo done flushing tc

# create prio queueing discipline
# http://lartc.org/howto/lartc.qdisc.classful.html
#  root 1:prio
#      /   |   \
# 10:sfq 20:sfq 30:sfq
tc qdisc add dev $IFACE root handle 1: prio

# icmp: high priority
tc filter add dev $IFACE protocol ip parent 1: prio 1 u32 match ip protocol 1 0xff flowid 1:1

## tcp: high priority
tc filter add dev $IFACE protocol ip parent 1: prio 1 u32 match ip protocol 6 0xff flowid 1:1

# udp blah: low priority
tc filter add dev $IFACE protocol ip parent 1: prio 1 u32 match ip dport $UDPPORT 0xffff flowid 1:3

echo tc filters created

echo tc done
