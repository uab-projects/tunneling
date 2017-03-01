#!/bin/bash
# Define parameters
GATEWAY=$1
SETUP_MODULE=$2
SETUP_OP=$3
	if [ "$3" == "" ]; then
		SETUP_OP="add"
	fi
TUNNEL_NAME=tunnel0
TUNNEL_DST_IPV4=0
TUNNEL_DST_IPV6=0
TUNNEL_IPSEC_CONF=0

# Parse parameters
function showUsage {
	echo "Usage: $0 GW1|GW2 basic|ipsec [delete|add]"
}
if [ $# -eq 0 ]; then 
	echo "Gateway to setup not specified"
	showUsage
	exit 1
elif [ $# -eq 1 ]; then
	echo "Module to setup not specified"
	showUsage
	exit 1
fi

# Get gateway and setup parameters
if [ $GATEWAY == "GW1" ]; then
	echo "Selected gateway is GW1"
	TUNNEL_DST_IPV4=10.0.3.2
	TUNNEL_DST_IPV6=2002::1/64
	TUNNEL_IPSEC_CONF=./ipsec-GW1.conf
elif [ $GATEWAY == "GW2" ]; then
	echo "Selected gateway is GW2"
	TUNNEL_DST_IPV4=10.0.0.1
	TUNNEL_DST_IPV6=2001::1/64
	TUNNEL_IPSEC_CONF=./ipsec-GW2.conf
else
	echo "Selected gateway does not exist"
	showUsage
	exit 1
fi

# Execute actions
if [ $SETUP_MODULE == "basic" ] ; then
	echo "   Adding tunnel..."
	ip tunnel add $TUNNEL_NAME mode sit remote $TUNNEL_DST_IPV4

	#Setting up
	ip link set dev $TUNNEL_NAME up

	#Routing rule
	ip -6 route add $TUNNEL_DST_IPV6 scope link dev $TUNNEL_NAME

	echo "Tunnel was added succesfully"

elif [ $SETUP_MODULE == "ipsec" ]; then
	if [ $SETUP_OP == "delete" ]; then
		echo "   Removing IPSEC (ESP & AH) configuration..."
		setkey -F
		setkey -P -F
		echo "   Configuration removed succesfully"
	else
		echo "   Adding IPSEC (ESP & AH) configuration..."
		setkey -f $TUNNEL_IPSEC_CONF
		echo "   IPSEC configuration was added succesfully"
	fi
else
	echo "Module to setup does not exist"
	showUsage
	exit 1
fi

