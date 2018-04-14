#!/bin/bash

# This script validates that we're connected to VPN and then launches Transmission and transmission-rss.  If we're not connected to VPN
# script will kill Transmission and transmission-rss.  

# This script leverages the open source project transmission-rss - https://github.com/nning/transmission-rss
# This script is designed to run as a LaunchAgent on macOS - /Library/LaunchAgents
# It is setup to run at an interval of every 5 minutes.


# Check VPN Status
URL='https://api.nordvpn.com/vpn/check/full'
JSON=$(curl -s $URL)

vpn_status=`echo $JSON | python -c 'import sys, json; data = json.load(sys.stdin); print "IP: %s (%s)\nStatus: %s" % (data["ip"], data["isp"], "\033[32mProtected" if data["status"] == "Protected" else "\033[31mUnprotected");' | grep "Protected"`
echo $vpn_status

# Once we're confirmed protect, move forward and launch Transmission app followed by transmission-rss to read in show feed
# http://showrss.info/timeline

if [ ! -z "$vpn_status" ]; then
    echo "We've confirmed we're protected, let's move forward"
    # Check to see if Transmission is already running, if it isn't launch
    pid=$(ps -fe | grep '[T]ransmission' | awk '{print $2}')
    if [[ -n $pid ]]; then
        echo "`date`: Transmission is running"
    else
        echo "`date`: Transmission is not running, opening application"
        open '/Applications/Transmission.app'
    fi
    sleep 5;
    # Check to see if transmission-rss is already running, if it isn't launch
    pid=$(ps -fe | grep '[t]ransmission-rss' | awk '{print $2}')
    if [[ -n $pid ]]; then
        echo "`date`: transmission-rss is running"
    else
        echo "`date`: transmission-rss is not running, opening application"
        /usr/local/bin/transmission-rss
    fi
    
else
    # VPN isn't connected, so check to see if apps are running, if they are kill them
    echo "Not Protected - Exiting and killing Torrent apps if they are running"
    pid1=$(ps -fe | grep '[T]ransmission' | awk '{print $2}')
    if [[ -n $pid1 ]]; then
        echo "Terminating Transmission App"
        kill $pid1
    fi
    pid2=$(ps -fe | grep '[t]ransmission-rss' | awk '{print $2}')
    if [[ -n $pid2 ]]; then
        echo "Terminating Transmission RSS App"
        kill $pid2
    fi
    
fi