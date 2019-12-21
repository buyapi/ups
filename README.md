## bash script for the Raspberry Pi to communicate with the ups board

# download the needed files

  wget -nd 

# open the script via nano or vim, and modify the following line as needed

  timer_min=10;

# change the permissions for the scripts

  sudo chmod 511 ups
  sudo chmod 511 ups.service

# move the script to the bin directory 

  sudo mv -f ups /bin/

# move the service file to the systemd directory 
  
  sudo mv -f ups.service /etc/systemd/system
