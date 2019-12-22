#!/bin/bash

os=$(uname -o);
declare -ru os;



if [ "$os" = "LIBREELEC" ] || [ "$os" = "OPENELEC" ]
then
    # these will run as normal, as the default user account is root
    wget --non-verbose --tries=3 https://raw.githubusercontent.com/buyapi/ups/master/scripts/ups;
    chmod --changes u=rx,g=rx,o=r ups;
    chown --changes root:root ups;
     
    wget --non-verbose --tries=3 https://raw.githubusercontent.com/buyapi/ups/master/scripts/elec.ups.service;
    chmod --changes u=rx,g=rx,o=r elec.ups.service;
    chown --changes root:root elec.ups.service;
    
    mkdir --parents /storage/.kodi/addons/.ups_power/bin/;
    mv --force ups /storage/.kodi/addons/.ups_power/bin/;
    chmod --changes u=rx,g=rx,o=rx /storage/.kodi/addons/.ups_power/;
  
    mv --force elec.ups.service /storage/.config/system.d/;
elif [ ]
then

else
    wget --non-verbose --tries=3 https://raw.githubusercontent.com/buyapi/ups/master/scripts/ups;
    chmod --changes u=rx,g=rx,o=r ups;
    chown --changes root:root ups;
    
    wget --non-verbose --tries=3 https://raw.githubusercontent.com/buyapi/ups/master/scripts/std_linux.ups.service;
    chmod --changes u=rx,g=rx,o=r std_linux.ups.service;
    chown --changes root:root std_linux.ups.service;

    mv --force ups /bin/;
    mv --force std_linux.ups.service /etc/systemd/system/;
fi
