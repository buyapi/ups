## bash script for the Raspberry Pi to communicate with the ups board

1. download the needed files
’’’
  wget -nd https://raw.githubusercontent.com/buyapi/ups/master/scripts/ups

  wget -nd https://raw.githubusercontent.com/buyapi/ups/master/scripts/ups.service
’’’
2. open the main ups script via nano or vim, and modify the following line as needed
’’’
  pwoff_timer_min=10;
’’’
3. change the permissions for the scripts
’’’
  sudo chmod 511 ups
  sudo chmod 511 ups.service
’’’
4. move the script to the bin directory 
’’’
  sudo mv -f ups /bin/
’’’
5. move the service file to the systemd directory 
’’’
  sudo mv -f ups.service /etc/systemd/system
’’’