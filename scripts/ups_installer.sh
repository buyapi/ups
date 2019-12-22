#!/bin/bash

os=$(uname -o);
declare -ru os;

wget --non-verbose --tries=3 https://raw.githubusercontent.com/buyapi/ups/master/scripts/ups;
wget --non-verbose --tries=3 https://raw.githubusercontent.com/buyapi/ups/master/scripts/ups.service;

chmod --changes u=rx,g=rx,o=r ups;
chmod --changes u=rx,g=rx,o=r ups.service;

chown --changes root:root ups;
chown --changes root:root ups.service;

if [ "$os" = "LIBREELEC" ] || [ "$os" = "OPENELEC" ]
then
        # these will run as normal, as the default user account is root

        mkdir --parents /storage/.kodi/addons/.ups_power/bin/;
        mv --force ups /storage/.kodi/addons/.ups_power/bin/;
        chmod --changes u=rx,g=rx,o=rx /storage/.kodi/addons/.ups_power/;
  
        sed --regexp-extended --expression="s:ExecStart=\/bin\/ups\/:ExecStart=\/storage\/\.kodi\/addons\/\.ups_power\/bin:" ups.service
        mv --force ups.service /storage/.config/system.d/;
elif [ ]
then

else
        mv --force ups /bin/;
        mv --force ups.service /etc/systemd/system/;
fi
