# Installation Instructions

First you may need to install the GNU make utility.

```bash
$ sudo apt install make
```

Since there are two options to use for the UPS Monitor there is a slight
difference in how they are installed.

```bash
$ cd /path/to/usb
```

## The Python Script

The default delay before shutdown is set in the `Makefile` to 600 seconds or
10 minutes. You can edit the *DEF_DELAY* variable to what ever you want.

```bash
$ sudo make install-py
```

## The bash Shell Script

The bash shell script has a default delay before shutdown set to 60 seconds
or one minute. You will need to edit the `script/ups.sh` script directly.
Look for the *delay* variable and change it to what ever you want.

```bash
$ sudo make install-shell
```

That's it, the UPS Monitor should be installed and running and will start
whenever the RPi is rebooted.

Oh, one last thing. If you want to try both just run the `install-*` again
for the other script. The `Makefile` will stop the running script and start
the other. And, remember to check the log file over time to see what happened.

[README](README.md)
