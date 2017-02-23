#!/bin/bash

set -e
#DefaultAdminPorts
WEB_PORT=8048
STORE_PORT=8148
ADAPTER_PORT=8248
ENTERPRISE_PORT=8348
REGISTRY_PORT=8448
PASSWORDFILE=/usr/src/glassfish/glassfish4/glassfish/passwordfile

# this if statement checks weather we only need to start the domains or set/change passwordfiles and to all the stuff below
if [ -f "$PASSWORDFILE" ]
then
	echo '##########Starting already created domains##########'
        ./restartCocome.sh
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

#Change password of WEB domain (necessarry for remote access to admin console 
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfileToChange change-admin-password --domain_name web

#Change password of STORE domain (necessarry for remote access to admin console 
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfileToChange change-admin-password --domain_name store

#Change password of ADAPTER domain (necessarry for remote access to admin console 
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfileToChange change-admin-password --domain_name adapter

#Change password of ENTERPRISE domain (necessarry for remote access to admin console 
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfileToChange change-admin-password --domain_name enterprise

#Change password of REGISTRY domain (necessarry for remote access to admin console 
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfileToChange change-admin-password --domain_name registry


############################################################################

#create database (default database DERBY is created when 'start-database' is executed
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin start-database 
# --> this automatically creates a default jdbc-pool (DerbyPool)

#######################################################################  


#start web domain
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile start-domain web

#start store domain
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile start-domain store 

#start adapter domain
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile start-domain adapter

#start enterprise domain
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile start-domain enterprise

#start registry domain
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile start-domain registry

##############################################################################

#create JDBC pool not necessary (created while starting database above)

#create jdbc connection CoCoMEDB with Passwordfile
#'jdbc/CoCoMEBD' at the end is the name of the ressource 
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin create-jdbc-resource --connectionpoolid DerbyPool --host localhost --port 8248 --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile jdbc/CoCoMEDB

############################################################################

#ENABLE remote access to admin console WEB domain
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile --port $WEB_PORT enable-secure-admin

#ENABLE remote access to admin console STORE domain
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile --port $STORE_PORT enable-secure-admin

#ENABLE remote access to admin console ADAPTER domain
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile --port $ADAPTER_PORT enable-secure-admin

#ENABLE remote access to admin console ENTERPRISE domain
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile --port $ENTERPRISE_PORT enable-secure-admin

#ENABLE remote access to admin console REGISTRY domain
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile --port $REGISTRY_PORT enable-secure-admin


#############################################################################

#### This part will be changed when mvn is executed ###
#### Important: registry and adapter have to be deployed before store and enterprise (they depent on registry/adapter)

#Deploy adapter8248.ear
echo '######### Deploy adapter8248.ear #########'
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile --port $ADAPTER_PORT deploy --force --name ADAPTER /usr/src/adapter8248.ear

#Deploy registry8448.war
echo '######### Deploy registry8448.war #########'
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile --port $REGISTRY_PORT deploy --force --name REGISTRY /usr/src/registry8448.war

#Deploy enterprise8348.ear
echo '######### Deploy enterprise8348.ear #########'
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile --port $ENTERPRISE_PORT deploy --force --name ENTERPRISE /usr/src/enterprise8348.ear


#Deploy store8148.ear
echo '######### Deploy store8148.ear #########'
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile --port $STORE_PORT deploy --force --name STORE /usr/src/store8148.ear


#Deploy web8048.war
echo '######### Deploy web8048.war #########'
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin --user admin --passwordfile /usr/src/glassfish/glassfish4/glassfish/passwordfile --port $WEB_PORT deploy --force --name WEB /usr/src/web8048.war



##############################################################################
#restart needed because of changed attributes like password
#Important notice: restart of the glassfish domains or start in general has to take playce in this order!
echo '########## restart database ##################'
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin stop-database 
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin start-database 

echo '########## restart domain ADAPTER ##################'
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin stop-domain adapter
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin start-domain  adapter

echo '########## restart domain REGISTRY ##################'
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin stop-domain registry
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin start-domain registry

echo '########## restart domain ENTERPRISE ##################'
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin stop-domain enterprise
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin start-domain enterprise

echo '########## restart domain STORE ##################'
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin stop-domain store
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin start-domain  store



# this demonstrates that cocome is up an running

netcat -l -p 8424


echo '########## restart domain WEB ##################'
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin stop-domain web
/usr/src/glassfish/glassfish4/glassfish/bin/asadmin start-domain -v web



echo '####### test ######'
# Last command was "-v" -> glassfish in verbose-mode -> registry-domain logs are printed out on console
#->  docker does not stop the container
# IMPORTANT:  No command will be executed after this Point!






