#!/bin/bash

# copy the ups script to init.d folder
cp ups.sh ~/etc/init.d/

# change permissions
chmod 755 /etc/init.d/ups.sh

#update rc.d file
update-rc.d ups.sh defaults
update-rc.d ups.sh enable
