## bash script to talk to the ups board

#change the permissions for the script 

  sudo chmod 511 ups

#copy the script to the init.d directory to run the script on startup

  sudo cp ups /etc/init.d/

#update the rc file

  sudo update-rc.d ups defaults
