#!/bin/bash
set -e

echo '####################  Restart   ####################### '

#################################################################################
echo "Wait for Cocome to start!"
#Wait for cocome to start. Cocome is up and running when the web-server 
# port 8048 is running as it is the last one that gets restarted.
while ! netcat -z cocome 8048; do   
  sleep 5.0 
  echo "Cocome is not running yet"
done

echo "CoCoME is running!"

#################################################################################


#start cocome-pickup domain domain
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile start-domain -v cocome-pickup


#start in vebose-mode -> docker container doesn't stop



