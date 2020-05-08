#!/usr/bin/env bash

# GPIO17 (input) used to read current power status.
# 0 - normal (or battery power switched on manually).
# 1 - power fault, swithced to battery.
echo 17 > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio17/direction

# GPIO27 (input) used to indicate that UPS is online
echo 27 > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio27/direction

# GPIO18 used to inform UPS that Pi is still working.
# After power-off this pin returns to Hi-Z state.
echo 18 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio18/direction
echo 0 > /sys/class/gpio/gpio18/value

LOG_FILE="/var/log/ups.log"

#
# $1 -- Lost Power Time
#
function message() {
    end_time=$(date +"%Y-%m-%dT%H:%M:%S.%N%:z")
    printf "UPS Power lost at: %s, Shoutdown at: %s\n" $1 $end_time >> $LOG_FILE
}

timeout=600
power_timer=0
inval_power="0"
ups_online1="0"
ups_online2="0"
ups_online_timer=0
lost_time=""

printf "Starting UPS at %s\n" $(date +"%Y-%m-%dT%H:%M:%S.%N%:z") >> $LOG_FILE

while true
do
    # Read GPIO27 pin value
    # Normally, UPS toggles this pin every 0.5s
    ups_online1=$(cat /sys/class/gpio/gpio27/value)

    sleep 0.1

    ups_online2=$(cat /sys/class/gpio/gpio27/value)

    let ups_online_timer=$ups_online_timer+1

    # toggled?
    if  [ "$ups_online1" != "$ups_online2" ]; then
        ups_online_timer=0
    fi

    # Reset all timers if ups is offline longer than 3s (no toggling detected)
    if [ $ups_online_timer -gt 30 ]; then
        #printf "ups_online_timer: %s\n" $ups_online_timer >> $LOG_FILE
        ups_online_timer=30
        power_timer=0
        inval_power=0
        #printf "UPS offline. Exit\n" >> $LOG_FILE
        #exit 0
    fi

    # Read GPIO17 pin value
    inval_power=$(cat /sys/class/gpio/gpio17/value)
    printf "inval_power: %s\n" $inval_power >> $LOG_FILE

    if [ "$inval_power" == "1" ]; then
        if [ "$lost_time" == "" ]; then
            lost_time=$(date +"%Y-%m-%dT%H:%M:%S.%N%:z")
        fi

        let power_timer=$power_timer+1
    else
        power_timer=0
        lost_time=""
    fi

    printf "power_timer: %s, timeout: %s\n" $power_timer $timeout >> $LOG_FILE

    # If power was not restored in $timeout/10 seconds
    if [ $power_timer -ge $timeout ]; then
        printf "power_timer: %s\n" $power_timer >> $LOG_FILE
        printf "Powering off...\n" >> $LOG_FILE
        message $lost_time
        sleep 2
        systemctl poweroff #turn off
        exit 0
    fi
done
