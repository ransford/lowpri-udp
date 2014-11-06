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

# UDP traffic to $UDPPORT is low priority
iptables -t mangle -A POSTROUTING -o $IFACE -p udp --dport $UDPPORT \
	-j CLASSIFY --set-class 1:12

# traffic with the min-delay flag is always high priority
iptables -t mangle -A POSTROUTING -o $IFACE -p tcp \
	-m tos --tos Minimize-Delay -j CLASSIFY --set-class 1:10


# all TCP traffic gets high priority
iptables -t mangle -A POSTROUTING -o $IFACE -p tcp -j CLASSIFY --set-class 1:10
iptables -t mangle -A POSTROUTING -o $IFACE -p udp -j CLASSIFY --set-class 1:10

# create a high-priority class
tc qdisc add dev $IFACE root handle 1: htb default 10

# udp to $UDPPORT is low-priority
echo 'problem after here?'
tc filter add dev $IFACE protocol ip parent 1:0 prio 2 u32 \
	match ip protocol 17 0xff \
	match udp dst $UDPPORT 0xffff \
	flowid 1:12

# create round-robin queueing disciplines *within* each queue to make sure that
# e.g.  high-priority TCP flows don't starve one another
tc qdisc add dev $IFACE parent 1:10 handle 20: sfq perturb 10
tc qdisc add dev $IFACE parent 1:12 handle 30: sfq perturb 10
