#!/bin/bash
set -e

echo '####################  Restart   ####################### '

#Important notice: the servers always have to be startet in this order,
#as they depend on each other!
#
#start database
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin start-database 

#start registry domain
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile start-domain registry

#start adapter domain
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile start-domain adapter

#start enterprise domain
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile start-domain enterprise

#start store domain
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile start-domain store 


#start web domain
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile start-domain -v web




