#!/bin/sh
# to be run on AP

PORT=58888 # UDP
RAND=$(od -N 128 /dev/urandom | shasum | cut -c1-8)

if [ $# -ne 1 ]; then
	echo "Usage: $0 otherhost" >&2
	exit 1
fi
OTHERNODE=$1; shift
FPREFIX="${OTHERNODE}-${RAND}"

echo "Experiment ID: ${RAND}"

# start tcpdump to measure jitter later.  note you should make tcpdump setuid
ssh "$OTHERNODE" "(sudo tcpdump -w ${FPREFIX}.pcap 'udp port ${PORT}' &) && iperf -u -s -p ${PORT}"
exit 0

### Measure occupancy vs. time:
# sample at 50 Hz
sudo ../chanbusy/chanbusy.py 50 > "${FPREFIX}.occupancy.csv"

### Run iperf for one minute:
# last column is throughput; interval is 0.5s; target 10M; UDP
TPUTCSV="${FPREFIX}.throughput.csv"
TPUTINTERVAL=0.5
echo "tstamp,srcaddr,srcport,dstaddr,dstport,n1,n2,n3,tput" > "$TPUTCSV"
iperf -c -u -b 10M -t 60 -p "$PORT" -i "$TPUTINTERVAL" -yc >> "$TPUTCSV"

# clean up
ssh "$OTHERNODE" killall iperf tcpdump

# copy pcap data to here
scp "$OTHERNODE":"${FPREFIX}.pcap" .

### Plot jitter vs. time:
# grab "time-since-last-matching-pkt,time-since-start-of-trace" CSV pairs from
# pcap file; plot jitter in R.
JITCSV="${FPREFIX}.jitter.csv"
echo "since_prev,since_start" > "$JITCSV"
tcpdump -t 5 -t 3 -r "${FPREFIX}.pcap" 'dst $OTHERNODE' | cut -d' ' -f1,2 | sed -e 's/ /,/' >> "$JITCSV"
./jitter.R "$JITCSV" "${FPREFIX}.jitter.pdf"

### Plot occupancy vs. time:
../chanbusy/chanbusy.R "${FPREFIX}.occupancy.csv" "$FPREFIX"

### Plot throughput vs. time:
./throughput.R "${FPREFIX}.throughput.csv" "$TPUTINTERVAL" "${FPREFIX}.throughput.pdf"
