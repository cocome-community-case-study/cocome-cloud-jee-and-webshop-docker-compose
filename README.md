This Project is about bringing together CoCoME and the Webshop-Project with Docker Compose. In a first step, it creates two containers. One's containing CoCoME as a single project which can be used seperately. The other is containing the Webshop, that needs a running instance of CoCoME to work. This is the part where docker compose comes into play: It links both containers, allowing them to communicate without any additional work for the user. This leads to the basic aim: Those containers can be multiplied and hosted on different machines for performance reasons. Solely the docker-compose file needs to be adjusted regarding the host adresses.

# Important: Without-Mvn-Version
This project-branch does not automatically build the newest version of CoCoME to reduce building time. As a new build takes about an hour, we decided not to pull the newest CoCoME (The version we are using is dated to the 23.February 2017). In the future, there will be another project which will download and build the newest CoCoMe and webshop.

# Preamble
The first thing we had to do was to adjust the mvn settings of both, CoCoME and the webshop. We changed the hosts in the CoCoME settings to ```cocome```. The reason for this is very simple: Docker routes the webshop demands to the CoCoME container which, in return, sends back the host name used in the settings. In case we use ```localhost```, the webshop would try to connect to (for example) the enterprise server by using ```localhost:EnterprisePort```. Unfortunately, docker does not route this request to the CoCoME container but to the webshop's localhost. Using ```cocome``` instead of ```localhost``` solves the problem, as docker now routes each requests to the CoCoME container ( ```links:cocome``` within the docker-compose file does the job here).
So for the future: Whenever this docker-compose file is used, the CoCoME and the Webshop settings.xml need to be adjusted. (The webshop can still be deployed on localhost for now). Both settings.xml.templates are on [GitHub](https://github.com/cocome-community-case-study/cocome-cloud-jee-and-webshop-docker-compose.git).

The most diffucult part was the starting order: The Webshop needs a running instance of CoCoME, as it needs the registry to register itself. Therefore, we had to tell the webshop container to create, start and the deploy the shop but to wait with a restart until CoCoME is up and running completely. As a solution, we used some TCP-Tools to ask the CoCoME container if it's ready. Furthermore, the authentication provider (Webshop) had to be updated as it has to match the new host adresses of cocome  ```cocome:PORT``` instead of ```localhost:PORT```. In the future, the authentication provider has to be updated during build time (mvn build) and moved to the location within its glassfish domain. More precisely: the authentification provider is the hub for the communication between webshop and CoCoME.
Remember: You need to run mvn compile, 2x package, 1x build(goal: clean compile package) when changing the settings as the "wsdl's" get generated in the first step, the stub's in the second step by using the wsdl's.

# Prerequisites
### Docker installation
- install Docker on your linux system. Use this [guide](https://docs.docker.com/engine/installation/linux/ubuntulinux/) for the installation.
- As a Windows user, install a VM on your PC and the latest version of Ubuntu. Then proceed with the linux-installation.
- It has not been tested on Mac so far.

### Docker-compose installation
- install docker-compose on your linux system. Use this [guide](https://docs.docker.com/compose/install/) for the installation. 
- Check your installation with: ```docker-compose version``` (Terminal)
- it has not been tested on Mac and Windows so far.

### Download the docker-compose file, dockerfiles and cocome
- Important: Do not download from the master-branch it does not contain the "Without-Mvn-Version".
- Change to branch: ```docker-compose-without-maven```
- Download the folder 'docker' from the [git repo](https://github.com/cocome-community-case-study/cocome-cloud-jee-and-webshop-docker-compose.git)

# Build and run the image
Open the terminal within the downloaded 'docker'-folder. You will see some scripts (which deploy, start, restart, stop CoCoME and the Webshop), the dockerfile for the Webshop, the dockerfile for CoCoME, some .war, .jar -files (this is the ```without-mvn workaround```) and most important: the docker-compose file.
When executing docker build, you always need do open the console within the folder that contains the dockerfile.
### Docker-compose build
- use follwing commands:  ```docker-compose build``` (This takes a few minutes as it downloads all the stuff our docker container needs. The second, third,... time will be faster).

### Docker-compose up
- use ```docker-compose up``` to run the image.(Remember, terminal needs to be opened within the folder with the compose file!)
- use ```docker-compose up --force-recreate``` if you want a new image. (```docker-compose up``` uses the cache and restarts the containers even if removed with docker-compose rm)
- the terminal will show all the log details.
- Use the docker logs to get information about a specific container. Therefore use the command ```docker ps``` to identify the containerID, then execute ```docker logs containerID -f``` with the actual containerID. (You can exit the log-view with Ctrl-C). You will notice that each domain will get started, stoped and restart. 

### Access the web interface
- Acces the CoCoME UI via your [browser](http://localhost:8080/cloud-web-frontend/)
- Acess the Webshop via your [browser](http://localhost:8580/cloud-pickup-shop/)
Important notice: localhost may vary on your system. This depends on you docker and operating system settings concerning local traffic.

### Deleting images and container
- If you want to delete all containers use ```docker rm -f $(docker ps -a -q)```
- To delete all images use ```docker rmi -f $(docker images -q)```
Important notice: ```docker-compose rm``` does not remove the images completely. Therefore, delete the containers with the command mentioned above.

### Troubleshooting
 - Nothing added yet

# Stop and start a container
###Stopping
- run ```docker-compose stop``` within your docker folder. This will force-stop both containers.
### Starting
- use ```docker-compose start``` to restart the container. 


# Implementation details & reasons

As mentioned in the preamble, we had serveral problems to face. In the following paragraphe, there will be a detailed explanation about problems we had to face and how we solved them. The paragraphe is seperated into several parts, one will be the CoCoME dockerfile, another will be the Webshop dockerfile and the docker-compose file. Finally a few information concernig the scripts we are using to deploy start the glassfish servers with CoCoME.
Notice: The part with the CoCoME dockerfile is quite similar to the single container version which is part of the repo [cocome-cloud-jee-docker](https://github.com/cocome-community-case-study/cocome-cloud-jee-docker).

## Dockerfile CoCoME

- starting with image ubuntu:16.04
	-> using the ubuntu image allows to use the Advanved Packaging Tool (apt) from ubuntu for installing required programs, such as git and maven

- using java8 installer
	-> cocome is a java based project, so java is necessary to execute commands like mvn install

- installing git python-virtualenv
	-> git version that run on docker. It is used for getting the files from git into the docker; maybe not the most efficient way, but, since cocome is developed on github, its the easiest way to get the most recent version of cocome

- installing maven 
	-> cocome is created as a maven project, so, in order to install it on the glassfish server, there has to be a version of maven. 

- using prepared glassfish version from github 
	-> we decided to provide a glassfish installation with all the domains CoCoME needs instead of downloading a new version from github. For two reasons, that seems to be the best way to get a working version of CoCoMe: First, Oracle stopped the Glassfish support, so there won't be a new version anyway. Second, we need to adjust some settings via the browser, This would be, as far as we know, too complticated with console commands.

- using a startdomain.sh script
    -> using a start script divides the docker commands and the glassfish related commands

- using dos2unix
    -> sometimes git changes the linux line-ending format to windows format or even worse: the user opens the startdomain.sh with notePad that causes this change too. Once changed, the execution will fail. This tool always changes it to linux style.
    
## Dockerfile Webshop

- this dockerfile is pretty similar to the CoCoME dockerfile. Therefor, there won't be a fully analysis as you can compare both of them.


## Docker-compose file

A docker-compose file is a text file in .yaml-format. To check the file for valid yaml syntax, we used [yamllint](http://yamllint.com/). It is highly recommended to check the dockerfile with this tool, as a wrong placed TAB or whitespace can destroy the whole file.
For this project we used docker-compose file syntax version 2, as the documentation was better than the doc for version one. There is no other reason for this decision, so the syntax version could easily be changed to another version.

- services: So far, thereare two services; CoCoME and the wenshop. Both have the same build context, as we use self-written dockerfiles for the setup.
- ports: this opens the port to the outside. As you can see above, we access CoCoME trough port 8080 and the webshop through 8580. Besides, docker uses the same ports inside the containers so that we need to forward the to thelocal machine the docker is running on. In words: 8080:8080 means "port 8080 inside the container shall be accessible through port 8080 on the local machine".
- links: this is the main task in this docker-compose file. It automatically links the webshop container with the CoCoME container (single direction only). Therefor, to access the CoCoME container from inside the Webshop, we only need to ping ```cocome:PORTNUMBER```. There is no need of any complicated TCP routing, changing iptables and so one. Notice: the name we used as service-name is the same we have to use as host name (here: cocome)




## startdomainCocome.sh
- if statement at the beginning
 -> When we  restart (stop and start) a docker container, we only need to start the domains again (without create and set passwords etc.). We used this workaround, as docker has no command for docker start with certain script. *docker start* automatically runs the startdomain.sh within the CMD command but this will start the whole process of password setting again. So, at the beginnig of startdomain.sh we ask the container wether it already created the passwordfile (this implicates that the container was already started at least one time) or not.

- adding password files and enabling secure admin
    -> Glassfish requires an enabled secure admin when executed in a docker environment. This needs a password file added to the domains (default: no password when domains were created)

- cloning the cocome repository 
 -> the purpose of this project has been to create an docker file which installs the most recent version of cocome into a container. By cloning the repository within the CMD call, the cloning process starts when the container is about to be created.
- last command in script is executed in --verbose mode
    -> Docker stops if no application is running foreground. As glassfish runs in background, the container would stop if the script is executed completely. So we decided to choose this workaround: the last domain is restarted in verbose mode, so glassfish enters the console and pretends to run foreground. Sadly there's one bad side effect: No command can be executed beyond this point. Maybe there's another solution which we did not find so far.

###Netcat  workaround
- netcat -l command at the end: this inconspicious line solves on of the biggest problem that accompanies CoCoME and docker, or docker in general. Docker provides some commands concerning the start order of the containers e.g.: one container does not start until the other is up and running. But, a running container does not imply a working container. For example: As soon as the CoCoME container is up, the start script gets executed. According to docker, the container is up and running now but inside, the script has still a bunch of work to do (starting, deploying, restarting...). There is no possibillity given by docker to change a running container in a "ready state". Therefore we had to find a workaround that solves this problem. We choosed to use a tool called netcat, which is a powerful tool for TCP requests. Right before the web-domain restarts we open a random port (we choosed 8424) and put netcat in listening mode. The script now gets stuck in this line until a tcp query will reach port 8424. This query is coming from the webshop thats not going to start until it gets a response from this port. In other words: the webshop queries this port every 5 seconds and doesn't get an answer until the CoCoME-script reaches the line where netcat gets started. By this time the backend is running and the container ready for any incoming connection.
####Problem: 
- There is an open window of 5 seconds which can cause serious trouble. 
- First: We open a random port. BUT: Due to docker, it is only possible to access the CoCoME container (and as a consequence this port) from inside the Webshop Container (docker link!)
- Second: The CoCoME container closes this port as soon as a query is coming in. If this query is not coming from the Webshop Container, it gets stuck in a endless loop waiting for this port to open.
---> So far, we did not find a better solutiion. Maybe, docker will introduce a command to set container in a ready mode, which can be called up by another container.
## restartCocome.sh
- this script gets executed only if the glassfish setup (password, enabling secure-admin etc) was executed before. In other words, this script is used when we restart a stopped container. 

## startdomainWebshop.sh
The main task of this script is to start the Webshop, wait for the CoCoME container to be ready and restart the servers.
- Glassfish adjustements are similar to the CoCoME script.
- the important part is the while loop at the end: After the glassfish adaption and webshop deploying is finished, the container needs to wait for CoCoME to be ready. As mentioned in the previous paragraphe, the webshop queries port 8424 of the CoCoME container with the netcat tool. As soon as is gets a connection, CoCoME is ready and the webshop gets restarted. This restart causes a new registration attempt of the webshop, which , by now, sould be successful. 

	

