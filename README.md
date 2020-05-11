# Buy A Pi UPS

Can be found in Canada at: [https://www.buyapi.ca/]
And in the United States at: [https://www.pishop.us/]

## The bash Script

This script is an updated version of the original. It fixes a few issues and
adds simple logging.

### Editable values

Change the delay before the RPi shuts down.

```bash
delay=60 # Delay shutdown for 60 seconds.
```
Changing it to 10 minutes
```bash
delay=600
```

Change the location of the log file.

```bash
LOG_FILE="/var/log/ups.log"
```
Changing it to a dir in the pi user.
```bash
LOG_FILE="/home/pi/log/ups.log"
```
Make sure the full path has been created before running the script.

## The Python Script

The Python script is a new addition. It has a few features that are not in
the bash script.

  1. This script can be run as the `pi` user, however you must change the
     logging path to the `pi` user also. This allows debugging without the
     need for root privileges.
  2. Change the log path with the `-l /path/to/my/log/file`.
  3. It has multiple logging levels, the DEBUG level can be turned on with
     the `-D` argument.
  4. The log path will be created if it does not exist already, but
     permissions to the full path are a necessity for this to work.
  5. The script will terminate if it does not find the UPS HAT connected,
     however, if this causes issues this feature can be turned off with the
     `-e False` argument.
  6. The delay before shutting down can be changed with the `-d 600` argument.
  7. A SIGTERM can be sent to the script to stop it (kill <pid>).

The help menu:

```bash
$ ./scripts/buy_a_pi_ups.py --help
usage: buy_a_pi_ups.py [-h] [-l LOG_FILE] [-d DELAY] [-e] [-D]

UPS processing...

optional arguments:
  -h, --help            show this help message and exit
  -l LOG_FILE, --log-file LOG_FILE
                        Log file path (Use absolute paths only default is
                        /var/log/ups.log).
  -d DELAY, --delay DELAY
                        Enter the delay before shutdown in seconds (default is
                        60 seconds).
  -e, --exit-no-ups     If set False this script will keep running if no ups
                        Hat is found (default True).
  -D, --debug           Run in debug mode, dumps a lot of log statements
                        (default is INFO level).
```

[Installation](INSTALL.md)
