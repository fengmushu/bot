#!/bin/sh 

DEV_NAME=$1
PID_FILE=$2
VERSION=$3
IS_TCP=$4

[ x"$IS_TCP" = x"1" ] && {
	IS_TCP=""
} || {
	IS_TCP="-u"
}

IPv4_ADDR=`ip addr show $DEV_NAME | grep -w inet | awk '{print $2}' | awk -F'/' '{print $1}'`
LOG_FILE="/tmp/iperf-${IPv4_ADDR}.log"
OUT_FILE="/tmp/iperf${VERSION}-${IPv4_ADDR}.log"
[ -z "${DEV_NAME}" ] && {
	DEV_NAME="br-wwan0"
}

prlog() {
	echo "$@" | tee -a $LOG_FILE
}

bring_up_iperf2() {
	iperf -s -i 1 $IS_TCP -1 -e -B $IPv4_ADDR -O $PID_FILE -o $OUT_FILE 2>&1 &
}

bring_up_iperf3() {
	iperf3 -s -i 1 -D -B $IPv4_ADDR -I $PID_FILE --logfile $OUT_FILE
}

bring_up_iperf() {
	[ "$VERSION" -eq 2 ] && {
		bring_up_iperf2
	} || {
		bring_up_iperf3
	}
}

mon_pid()
{
	PID=`cat $PID_FILE` 2> /dev/null
	[ -n "$PID" ] && [ -d /proc/$PID ] && {
		prlog "$PID" `date +%H-%m-%S`
	} || {
		bring_up_iperf || {
			exit 0
		}
	}
}
# mon_pid

WAIT=0
while [ $WAIT -le 3600 ]
do
	mon_pid
	let WAIT=$WAIT+1
	sleep 1
done

