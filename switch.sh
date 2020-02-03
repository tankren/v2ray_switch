#!/bin/sh
echo "Running..."
sv1="replace your server here"
sv2=""
sv3=""
sv4=""
sv5=""
sv6=""
sv7=""
sv8=""
sv9=""

COUNT=4

echo "==================================================================================================" >> /etc/v2ray/switch.log
echo "$(date +%Y/%m/%d-%H:%M:%S): Start to ping all servers for $COUNT Times" >> /etc/v2ray/switch.log

P1=$(ping -W 1 -c $COUNT $sv1 | grep 'avg' | awk -F '/' '{ print $6 }' | awk -F '.' '{ print $1 }')
P2=$(ping -W 1 -c $COUNT $sv2 | grep 'avg' | awk -F '/' '{ print $6 }' | awk -F '.' '{ print $1 }')
P3=$(ping -W 1 -c $COUNT $sv3 | grep 'avg' | awk -F '/' '{ print $6 }' | awk -F '.' '{ print $1 }')
P4=$(ping -W 1 -c $COUNT $sv4 | grep 'avg' | awk -F '/' '{ print $6 }' | awk -F '.' '{ print $1 }')
P5=$(ping -W 1 -c $COUNT $sv5 | grep 'avg' | awk -F '/' '{ print $6 }' | awk -F '.' '{ print $1 }')
P6=$(ping -W 1 -c $COUNT $sv6 | grep 'avg' | awk -F '/' '{ print $6 }' | awk -F '.' '{ print $1 }')
P7=$(ping -W 1 -c $COUNT $sv7 | grep 'avg' | awk -F '/' '{ print $6 }' | awk -F '.' '{ print $1 }')
P8=$(ping -W 1 -c $COUNT $sv8 | grep 'avg' | awk -F '/' '{ print $6 }' | awk -F '.' '{ print $1 }')
P9=$(ping -W 1 -c $COUNT $sv9 | grep 'avg' | awk -F '/' '{ print $6 }' | awk -F '.' '{ print $1 }')

if [ "$P1" = "" ]; then P1="999"
	fi
if [ "$P2" = "" ]; then P2="999"
	fi
if [ "$P3" = "" ]; then P3="999"
	fi
if [ "$P4" = "" ]; then P4="999"
	fi
if [ "$P5" = "" ]; then P5="999"
	fi
if [ "$P6" = "" ]; then P6="999"
	fi
if [ "$P7" = "" ]; then P7="999"
	fi
if [ "$P8" = "" ]; then P8="999"
	fi
if [ "$P9" = "" ]; then P9="999"
	fi

PB=$(echo $P1 $P2 $P3 $P4 $P5 $P6 $P7 $P8 $P9 |xargs -n1|sort -n|head -1)

if [ $PB -eq $P1 ]; then
	new_server=$sv1 
elif [ $PB -eq $P2 ]; then
	new_server=$sv2 
elif [ $PB -eq $P3 ]; then
	new_server=$sv3 
elif [ $PB -eq $P4 ]; then
	new_server=$sv4 
elif [ $PB -eq $P5 ]; then
	new_server=$sv5 
elif [ $PB -eq $P6 ]; then
	new_server=$sv6 
elif [ $PB -eq $P7 ]; then
	new_server=$sv7 
elif [ $PB -eq $P8 ]; then
	new_server=$sv8 
elif [ $PB -eq $P9 ]; then
	new_server=$sv9
fi
	
echo "$(date +%Y/%m/%d-%H:%M:%S): Best server is $new_server, latency is $PB ms" >> /etc/v2ray/switch.log

current_server=$(cat /etc/v2ray/config.json |grep 'mitsuha' | head  -1| awk -F '"' '{ print $4 }')
PC=$(ping -W 1 -c $COUNT $current_server | grep 'loss' | awk -F ',' '{ print $3 }' | awk -F "%" '{ print $1 }')
PS=$(ping -W 1 -c $COUNT $current_server | grep 'avg' | awk -F '/' '{ print $6 }' | awk -F '.' '{ print $1 }')
if [ $PS = "" ]; then PS="999"
	fi
echo "$(date +%Y/%m/%d-%H:%M:%S): Current server is $current_server, $PC % packet loss, latency is $PS ms" >> /etc/v2ray/switch.log

if [ $PC -gt "0" ]; then
	echo "$(date +%Y/%m/%d-%H:%M:%S): Current server is not stable, changing to $new_server" >> /etc/v2ray/switch.log
	sed -i -e "s/$current_server/$new_server/g" /etc/v2ray/config.json
	systemctl restart v2ray
	echo "$(date +%Y/%m/%d-%H:%M:%S): Server switch is done successfully" >> /etc/v2ray/switch.log
	sleep 10s
	speedtest=$(curl -o /dev/null -s -w %{speed_download} -x socks5://127.0.0.1:1080 https://cachefly.cachefly.net/10mb.test)	
	mps=$(echo "scale=2;$speedtest/1000000" |bc)
	echo "$(date +%Y/%m/%d-%H:%M:%S): Speedtest of new server is $mps MB/s" >> /etc/v2ray/switch.log
	if [ $(echo "$mps < "1"" |bc) -eq 1 ]; then
		echo "$(date +%Y/%m/%d-%H:%M:%S): New server is too slow, run again" >> /etc/v2ray/switch.log
		echo "New server is too slow, run again"
		sh /etc/v2ray/switch.sh
		exit
	fi
		elif [ $current_server != $new_server ]; then
			echo "$(date +%Y/%m/%d-%H:%M:%S): Current server is not the best, changing to $new_server" >> /etc/v2ray/switch.log
			sed -i -e "s/$current_server/$new_server/g" /etc/v2ray/config.json
			systemctl restart v2ray
			echo "$(date +%Y/%m/%d-%H:%M:%S): Server switch is done successfully" >> /etc/v2ray/switch.log
			sleep 10s
			speedtest=$(curl -o /dev/null -s -w %{speed_download} -x socks5://127.0.0.1:1080 https://cachefly.cachefly.net/10mb.test)	
			mps=$(echo "scale=2;$speedtest/1000000" |bc)
			echo "$(date +%Y/%m/%d-%H:%M:%S): Speedtest of new server is $mps MB/s" >> /etc/v2ray/switch.log
			if [ $(echo "$mps < "1"" |bc) -eq 1 ]; then
				echo "$(date +%Y/%m/%d-%H:%M:%S): New server is too slow, run again" >> /etc/v2ray/switch.log
				echo "New server is too slow, run again"
				sh /etc/v2ray/switch.sh
				exit
			fi
else
	echo "$(date +%Y/%m/%d-%H:%M:%S): Current server is ok, no changing" >> /etc/v2ray/switch.log
fi

echo "Done, please refer to log file /etc/v2ray/switch.log for the detailed result"
