#!/bin/bash
set -e

echo '####################  Restart   ####################### '


#start cocome-pickup domain domain
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile start-domain -v cocome-pickup



