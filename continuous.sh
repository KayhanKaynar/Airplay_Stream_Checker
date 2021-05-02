#!/bin/bash
#
# Kayhan KAYNAR 2021
# kayhan.kaynar@hotmail.com

clientonlinefile=/tmp/airplayclientonline.txt

service_port_check () {
port=$( netstat -ltnp | grep rpiplay | cut -d ":" -f2 | cut -f1 -d' ' )
echo $port
}

declare RESULT=($( service_port_check  ))  # (..) = array
echo "First airplay port: ${RESULT[0]}"

while :
do

( netstat -natu | grep 'ESTABLISHED' | grep ${RESULT[0]} )

if [ $? -eq 0 ]
then
  if [ ! -e $clientonlinefile ]
    then
    tvservice -p
    touch $clientonlinefile
  fi
  echo "Airplay client bagli."
  vcgencmd display_power 1
else
  if [ -e $clientonlinefile ]
    then
    rm $clientonlinefile
    vcgencmd display_power 0
    echo "Airplay client bagli degil."
  fi
fi

sleep 10

done

exit 0
