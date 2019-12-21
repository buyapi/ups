## bash script for the Raspberry Pi to communicate with the ups board

# download the needed file

# open the script via nano or vim, and modify the following line as needed

  timer_min=10;

# change the permissions for the script 

  sudo chmod 511 ups

# move the script to the bin directory 

  sudo mv -f ups /bin/

