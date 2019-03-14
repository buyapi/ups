#!/bin/bash

#GPIO17 (input) used to read current power status. 
#0 - normal (or battery power switched on manually). 
#1 - power fault, swithced to battery. 
echo 17 > /sys/class/gpio/export;
echo in > /sys/class/gpio/gpio17/direction;

#GPIO27 (input) used to indicate that UPS is online
echo 27 > /sys/class/gpio/export;
echo in > /sys/class/gpio/gpio27/direction;

#GPIO18 used to inform UPS that Pi is still working. After power-off this pin returns to Hi-Z state. 
echo 18 > /sys/class/gpio/export;
echo out > /sys/class/gpio/gpio18/direction;
echo 0 > /sys/class/gpio/gpio18/value;

power_timer=0;
inval_power="0";

ups_online1="0";
ups_online2="0";
ups_online_timer="0";

while true
do
	#read GPIO27 pin value
	#normally, UPS toggles this pin every 0.5s
	ups_online1=$(cat /sys/class/gpio/gpio27/value);
	
	sleep 0.1;
	
	ups_online2=$(cat /sys/class/gpio/gpio27/value);
	
	ups_online_timer=$((ups_online_timer+1));
	
	#toggled?
	if  (( "$ups_online1" != "$ups_online2" )); then
		ups_online_timer=0;
	fi
	
	#reset all timers if ups is offline longer than 3s (no toggling detected)
	if (("$ups_online_timer" > 30)); 
	then
		echo "$ups_online_timer";
		
		ups_online_timer=30;
		power_timer=0;
		inval_power=0;
		#echo "UPS offline. Exit";
		#exit;
	fi		

	#read GPIO17 pin value
	inval_power=$(cat /sys/class/gpio/gpio17/value);
	
#	echo $inval_power;
	
	if (( "$inval_power" == 1 )); then
		power_timer=$((power_timer+1));
	else 
		power_timer=0;
	fi
	
	#If power was not restored in 5 seconds
	if (( "$power_timer" == 50 )); then 
		#echo $power_timer;
		echo "Powering off..."
		sleep 2;
		systemctl poweroff; #turn off
		exit;
	fi	
done
	