#!/bin/sh
# to be run on AP

if [ $# -ne 1 ]; then
	echo "Usage: $0 otherhost" >&2
	exit 1
fi
OTHERNODE=$1; shift

# start tcpdump to measure jitter later.  note you should make tcpdump setuid
ssh "$OTHERNODE" '(sudo tcpdump -w foo.pcap "udp port 58888" &) && iperf -u -s -p 58888'
exit 0

# XXX start measuring occupancy using my kernel reading method

# last column is throughput; interval is 0.5s; target 10M; UDP
iperf -c -u -b 10M -t 60 -p 58888 -i 0.5 -yc > foo.csv

ssh "$OTHERNODE" sudo killall iperf tcpdump

scp "$OTHERNODE":foo.pcap .

# grab "time-since-last-matching-pkt,time-since-start-of-trace" CSV pairs from
# pcap file
JITCSV=foo-jitter.csv
echo "since_prev,since_start" > "$JITCSV"
tcpdump -t 5 -t 3 -r foo.pcap 'dst $OTHERNODE' | cut -d' ' -f1,2 | sed -e 's/ /,/' > "$JITCSV"
./jitter.R "$JITCSV"

# XXX generate plot of throughput vs. time
# XXX generate plot of jitter vs. time
# XXX generate plot of occupancy vs. time
