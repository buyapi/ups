#!/usr/bin/env bash
#
# To change the delay before shutdown update the `delay` variable below.
# This variable is in seconds, so 5 minutes would be 60*5 or 300 seconds.
#

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
delay=60 # Delay shutdown for 60 seconds.
power_failed=0
lost_time=""


#
# $1 -- date time ie. 2020-01-10 19:00:22.968125
#
timestamp() {
    date +'%Y%m%d%H%M%S%N' --date="$1"
}


is_ups_running() {
    toggle_hi=0
    toggle_lo=0
    count=6

    while [ $count -ge 1 ]; do
        value=$(cat /sys/class/gpio/gpio27/value)

        if [ value -eq 1 ]; then
            let toggle_hi=$toggle_hi+1
        else
            let toggle_lo=$toggle_lo+1
        fi

        sleep 0.5
        let count=$count-1

    done

    let value=$toggle_hi-$toggle_lo

    if [ ${value#-} -le 2 ]; then
        result=1
    else
        result=0
    fi

    return $result
}


printf "Starting UPS at %s\n" $(date +"%Y-%m-%dT%H:%M:%S.%N%:z") >> $LOG_FILE

while true
do
    # Read GPIO27 pin value
    # Normally, UPS toggles this pin every 0.5s
    is_ups_running

    if [ $? -eq 0 ]; then
        printf "DEBUG--ups_online_timer: %s\n" $ups_online_timer >> $LOG_FILE
        printf "UPS HAT offline. Exiting\n" >> $LOG_FILE
        exit 0
    fi

    # Read GPIO17 pin value
    power_failed=$(cat /sys/class/gpio/gpio17/value)
    printf "power_failed: %s\n" $power_failed >> $LOG_FILE

    if [ $power_failed -eq 1 ]; then
        if [ "$lost_time" == "" ]; then
            lost_time=$(date +"%Y-%m-%dT%H:%M:%S.%N%:z")
        fi
    else
        lost_time=""
    fi

    if [ $lost_time != "" ]; then
        now=$(date +"%Y-%m-%dT%H:%M:%S.%N%:z")
        let new_delay=$delay*1000000000
        let time_delta=$(timestamp $lost_time)+$new_delay

        # If power was not restored in $delay seconds
        if [ $time_delta -le $(timestamp $now) ]; then
            printf "Powering off...\n" >> $LOG_FILE
            printf "UPS Power lost at: %s, Shutting down at: %s\n" \
                   $lost_time $now >> $LOG_FIL
            sleep 2
            systemctl poweroff #turn off
            exit 0
        fi
    fi
done
