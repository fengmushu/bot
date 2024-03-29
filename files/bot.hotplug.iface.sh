#!/bin/sh

# VAR		Description
# -----------------------------------
# ACTION	ifdown, ifup, ifup-failed, ifupdate, free, reload, iflink, create
# INTERFACE	Name of the logical interface which went up or down (e.g. wan or lan)
# DEVICE	Name of the physical device which went up or down (e.g. eth0 or br-lan or pppoe-wan), when applicable

# When ACTION is ifupdate, the following environment variables may be set

# Variable 		Description
# ------------------------------------
# IFUPDATE_ADDRESSES	1 if address changed since previous ifupdate event
# IFUPDATE_ROUTES	1 if a route changed since previous ifupdate event
# IFUPDATE_PREFIXES	1 if prefix changed since previous ifupdate event
# IFUPDATE_DATA		1 if ubus call network.interface.$INTERFACE set_data ... (or equivalent) happened

case $INTERFACE in
	wwan*)
	;;
	*)
		logger "bot ignore $DEVICE=$INTERFACE $ACTION"
		exit 0
	;;
esac

BOTC=`which bot`
BOT_v2_PIDFILE="/var/run/bot-v2-$DEVICE.pid"
BOT_v3_PIDFILE="/var/run/bot-v3-$DEVICE.pid"
BOT_v2_PID=`cat $BOT_v2_PIDFILE`
BOT_v3_PID=`cat $BOT_v3_PIDFILE`

unset DEV
unset NETWORK
unset IS_TCP
unset RATELIMIT

load_bots() {
	local dev
	local network
	local istcp
	local ratelimit
	
	config_get dev $1 dev
	config_get network $1 network
	config_get istcp $1 istcp
	config_get ratelimit $1 ratelimit
	
	[ -n "$dev" ] && DEV=$dev
	[ -n "$network" ] && NETWORK=$network
	[ -n "$istcp" ] && IS_TCP=$istcp
	[ -n "$ratelimit" ] && RATELIMIT=$ratelimit
}

config_load system
config_foreach load_bots bot

start_bot() {
	logger starting bot $DEV $NETWORK
	$BOTC "$DEVICE" "$BOT_v2_PIDFILE" "2" "$IS_TCP" "$RATELIMIT" 2> /dev/null &
	$BOTC "$DEVICE" "$BOT_v3_PIDFILE" "3" "$IS_TCP" "$RATELIMIT" 2> /dev/null &
}

stop_bot() {
	VERSION=$1
	eval "BOT_PIDFILE=\"\$BOT_v${VERSION}_PIDFILE\""
	eval "BOT_PID=\"\$BOT_v${VERSION}_PID\""
	logger stopping bot $DEV pidfile, $BOT_PIDFILE $BOT_PID
	kill $BOT_PID
	rm -f $BOT_PIDFILE
}

case "${ACTION:-ifup}" in
	ifupdate|ifup)
		[ -z "$BOT_v2_PID" ] || stop_bot 2
		[ -z "$BOT_v3_PID" ] || stop_bot 3
		start_bot
	;;
	ifdown)
		stop_bot 2
		stop_bot 3
	;;
	*)
		logger "$ACTION of $DEVICE not found"
	;;
esac


