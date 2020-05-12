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

The default delay before shutdown is set in the makefile to 600 seconds or
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

That's it, the UPS Monitor should be installed and up and running.
