#!/bin/bash
#
# This project is written by kayhan.kaynar@hotmail.com for using rpiplay instance as a Raspberry Pi AirPlay server.
# When using rpiplay , sometimes when you connect to the service, rpiplay instance gets null buffer error
# and then crashes with some video,audio problems. This script is written to fix the problem with an innovative perspective.
# The script detects  if a client is connected, and if the client disconnects because of a sound or smt else problem, 
# script detects it and then restarts the rpiplay instance.
# For RPiPlay setup and usage:
# RPiPlay : https://github.com/FD-/RPiPlay.git
#
# Kayhan Kaynar , October, 2022
# AirPlay Service Checker V3
# kayhan.kaynar@hotmail.com

### From here --->
myname=`basename $0`

for pid in $(pidof -x $myname); do
    if [ $pid != $$ ]; then
        #echo "[$(date)] : $myname : Process is already running with another PID of $pid"
        exit 1
    #else
        #echo There is no other instances working.
    fi
done
### ----> to here script finds if itself is running in another instance with its name.

# Some variables like;
sleeptimer=15
tvname=KayhanPI4

# Checking if another rpiplay instance is running in background
check_if_multiplerpiplay_is_running(){
local rpiplaypids=($(pidof rpiplay))
instancecount="${#rpiplaypids[@]}"

# Killing if other instances have been found.
if [ $instancecount -gt "1" ] ;then
N=0
while [ "$N" -ne "$arraylength" ]; do
        kill -9 ${rpiplaypid[N]}
        ((N=N+1))
done
fi

# Somehow , if script can not find any instance, it starts one of it , itself:
local rpiplaypid2=($(pidof rpiplay))
if [ -z $rpiplaypid2 ]
        then
        /usr/local/bin/rpiplay -n $tvname -b off -vr rpi -ar rpi -a hdmi -l &
        tvservice -p
unset rpiplaypid
fi
}

service_port_finder(){
port=$( netstat -ltnp | grep rpiplay | cut -d ":" -f2 | cut -f1 -d' ' )
echo $port
}


while :
do

check_if_multiplerpiplay_is_running
declare PORTS=($(service_port_finder))
# Finding the first airplay service port
#echo "Airplay is running on port: ${PORTS[0]}"

netstat -natu | grep 'ESTABLISHED' | grep ${PORTS[0]}  > /dev/null
status=$?

if [ $status -eq 0 ]
then
  if [ ! -e $clientonlinefile ]
    then
    tvservice -p
    touch $clientonlinefile
  fi
  echo "Airplay client connected."
  vcgencmd display_power 1 > /dev/null
else
  if [ -e $clientonlinefile ]
    then
    rm $clientonlinefile
    vcgencmd display_power 0 > /dev/null
    rpiplaypid=($(pidof rpiplay))
    kill -9 $rpiplaypid
    unset rpiplaypid
    /usr/local/bin/rpiplay -n $tvname -b off -vr rpi -ar rpi -a hdmi -l &
    echo "Airplay client disconnected."
  fi
fi
sleep $sleeptimer

done

exit 0
