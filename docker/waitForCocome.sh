#!/bin/bash

echo "Wait for Cocome to start!"
#8424 will be redirected to a running glassfish port as soon as cocome is running
#8424 is just a random pick!
while ! netcat -z cocome 8424; do   
  sleep 5.0 
   
  echo "Cocome is not running yet"
done

echo "CoCoME is running!"

sh ./startdomainWebshop.sh

echo "startWebshop from waitForCocome Script"
