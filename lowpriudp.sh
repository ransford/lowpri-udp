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
#  root 1:prio
#   /        \
# 10:sfq   20:sfq
tc qdisc replace dev $IFACE root handle 1: prio
echo created root
tc qdisc add dev $IFACE parent 1:1 handle 10: sfq
echo created 1:10
tc qdisc add dev $IFACE parent 1:2 handle 20: sfq
echo created 1:20

# udp to $UDPPORT is low-priority
#echo adding filter for $UDPPORT/udp
#tc filter add dev $IFACE protocol ip parent 1:0 prio 2 u32 \
#	match ip protocol 17 0xff \
#	match udp dst $UDPPORT 0xffff \
#	classid 1:20
#echo done adding filter

# clear existing iptables tomfoolery
echo flushing iptables...
iptables -t mangle -F
echo done flushing iptables

# UDP traffic to $UDPPORT is low priority
iptables -t mangle -A POSTROUTING -o $IFACE -p udp --dport $UDPPORT \
	-j CLASSIFY --set-class 1:20

# traffic with the min-delay flag is always high priority
iptables -t mangle -A POSTROUTING -o $IFACE -p tcp \
	-m tos --tos Minimize-Delay -j CLASSIFY --set-class 1:10


# all TCP traffic gets high priority
iptables -t mangle -A POSTROUTING -o $IFACE -p tcp -j CLASSIFY --set-class 1:10
iptables -t mangle -A POSTROUTING -o $IFACE -p udp -j CLASSIFY --set-class 1:10
echo iptables done

echo tc done
