# Installation Instructions

First you may need to install the GNU make utility.

```bash
$ sudo apt install make
```

Since there is a shell and a python script either of which can be used as
the UPS Monitor there is a slight difference in how they are installed. Also
if you install one then the other the first one installed will be overwritten
by the second, so going back and forth between them is possible.

```bash
$ cd /path/to/buy_a_pi_usb
```

## The Python Script

For the Python script only the default delay before shutdown can be set in
the `Makefile` to whatever you want.

```bash
DEF_DELAY = 600 # 10 minutes
```

Then run the command below to install it.

```bash
$ sudo make install-py
```

## The bash Shell Script

The bash shell script has a default delay before shutdown set to 60 seconds
or one minute. You will need to edit the `script/ups.sh` script directly.
Look for the *delay* variable and change it to whatever you want. Do not use
spaces either before or after the `=`.

```bash
delay=600 # 10 minutes
```

Then run the command below to install it.

```bash
$ sudo make install-shell
```

That's it, the UPS Monitor should be installed and running and will start
whenever the RPi is rebooted.

Oh, one last thing. If you want to try both just run the `install-*` again
for the other script. The `Makefile` will stop the running script and start
the other. And, remember to check the log file over time to see what happened.

### Running the Python Script as a Non-Root User

This should only be done for testing. See the README for other possible
arguments.

```bash
$ ./scripts/buy_a_pi_ups.py -l /tmp/ups.log -d 300
```

The above command will put the log file in `/tmp` and the time before shut
down is set to 5 minutes.

[README](README.md)
