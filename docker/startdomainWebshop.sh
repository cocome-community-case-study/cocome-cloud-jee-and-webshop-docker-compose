#!/bin/bash

set -e
#DefaultAdminPorts

COCOME_PICKUP_PORT=8548
PASSWORDFILE=/usr/src/glassfish/glassfish4/glassfish/passwordfile

# this if statement checks weather we only need to start the domains or set/change passwordfiles and to all the stuff below
if [ -f "$PASSWORDFILE" ]
then
	echo '##########Starting already created domains##########'
        ./restartWebshop.sh
        exit 0
else
	echo '##########creating and starting domains'
fi


#The "echos" are visible via "docker logs IMAGEID" after using docker run
#You get the imageID of the running container  with 'docker ps'  or the id of all containers via 'docker ps -a'
#Touch creates two new files
touch /usr/src/glassfish/glassfish4/glassfish/passwordfileToChange
touch /usr/src/glassfish/glassfish4/glassfish/passwordfile

#Create File to change password (this is a work-around, as we use existing domains!)
echo "AS_ADMIN_PASSWORD=" > /usr/src/glassfish/glassfish4/glassfish/passwordfileToChange
echo "AS_ADMIN_NEWPASSWORD=${PASSWORD}" >> /usr/src/glassfish/glassfish4/glassfish/passwordfileToChange

#Create password file 
echo "AS_ADMIN_PASSWORD=${PASSWORD}" >> /usr/src/glassfish/glassfish4/glassfish/passwordfile

############################################################################

#Change password of COCOME-PICKUP domain (necessarry for remote access to admin console 
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfileToChange change-admin-password --domain_name cocome-pickup

############################################################################

#start cocome-pickup domain
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile start-domain cocome-pickup
##############################################################################


#ENABLE remote access to admin console COCOME-PICKUP domain
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile --port $COCOME_PICKUP_PORT enable-secure-admin

#############################################################################

#### This part will be changed when mvn is executed ###
#### Important: registry and adapter have to be deployed before store and enterprise (they depent on registry/adapter)


#Deploy cocomepickup8548.war
echo '######### Deploy cocome_pickup8548.war #########'
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile --port $COCOME_PICKUP_PORT deploy --force --name PICKUPSHOP /usr/src/cocomepickup8548.war


##############################################################################
#restart needed because of changed attributes like password
#Important notice: restart of the glassfish domains or start in general has to take playce in this order!


echo '########## restart domain cocome-pickup ##################'
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin stop-domain cocome-pickup
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin start-domain -v cocome-pickup



echo '####### test ######'
# Last command was "-v" -> glassfish in verbose-mode -> registry-domain logs are printed out on console
#->  docker does not stop the container
# IMPORTANT:  No command will be executed after this Point!






