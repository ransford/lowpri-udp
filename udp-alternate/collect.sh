#!/bin/sh

if [ $# -ne 2 ]; then
	echo "Usage: $0 iface1 iface2 [... ifaceN]" >&2
	exit 1
fi
IFACES=$*
PORT=$(grep 'define PORT' udpalt.c | sed -e 's/.* "//' -e 's/"//')

for iface in $IFACES; do
	sudo tcpdump -i "$iface" -w udp-alt-$iface.pcap "udp dst port $PORT" &
done

echo "When done, run:"
echo "\tsudo killall tcpdump"
