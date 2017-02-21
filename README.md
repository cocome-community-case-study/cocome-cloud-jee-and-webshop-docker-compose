This project is about developing a dockerfile, which, in a first step creates an docker image with basic functionality. In a second step, while running that image, it installs the latest version of the cocome project onto an container and makes it runable. This gives the option to try out cocome on each computer, with docker installed, without having to proceed the installation of cocome.


# Prerequisites
### Docker installation
- install Docker on your linux system. Use this [guide](https://docs.docker.com/engine/installation/linux/ubuntulinux/) for the installation.
- As a Windows user, install a VM on your PC and the latest version of Ubuntu. Then proceed with the linux-installation.
- It has not been tested on Mac so far.

### Download the Dockerfile
- Download the folder 'docker' from the [git repo](https://github.com/cocome-community-case-study/cocome-cloud-jee-docker.git)

# Build and run the image
Open the terminal within the downloaded 'docker'-folder. When executing docker build, you always need do open the console within the folder that contains the dockerfile.
### Docker build
- use follwing command:  ```docker build -t someName .```
- you can exchange 'someName' to whatever you want. This will be the image name. Very important: do not forget the fullstop after the name.
- it takes some time when executed the first time as it needs to dowload ubuntu, java, glassfish a some other files.
- You need to rebuild the image to get a new version of CoCoME
- check if the image was created successfully by using the command *docker images*. The image name should appear under REPOSITORY.

### Docker run
- use ```docker run -d -p 8080:8080 someName``` to run the image.
- it takes some time to start each glassfish domain, execute maven to deploy CoCoME on the domains(around 30 to 45 minutes).
- Use the docker logs to get information about the progress. Therefore use the command ```docker ps``` to identify the containerID, then execute ```docker logs containerID -f``` with the actual containerID. (You can exit the log-view with Ctrl-C). You will notice that each domain will get started, stoped and restart. After that, you should be able to access the CoCoME UI via your [browser](http://localhost:8080/cloud-web-frontend/)

### Docker run full access
- If you need full access to each glassfish domain use the command ```docker run -d -p 8048:8048 -p 8080:8080 -p 8148:8148 -p 8180:8180 -p 8248:8248 -p 8280:8280 -p 8348:8348 -p 8380:8380  -p 8448:8448 -p 8480:8480 someName```

### Deleting images and container
- If you want to delete all containers use ```docker rm -f $(docker ps -a -q)```
- To delete all images use ```docker rmi -f $(docker images -q)```

### Troubleshooting
 - Nothing added yet

# Stop and start a container
###Stopping
- run from a bash session within the container: ```docker exec -it containerID /bin/bash``` then just type in: ```./stopdomain.sh``` OR
- use the command ```docker exec containerID ./stopdomain.sh``` 
  -> both commands stop the glassfish domains which leads to a docker stop, as no application is running
### Starting
- use ```docker ps -a``` to get the containerID of the stopped container, then execute ```docker start containerID```

# Logfiles (glassfish)
- As docker hides its image/container data, we need to access the glassfish logfiles via the web browser. Therefore the admin ports have to be exposed. This needs the docker run full access command (see above).
- access the glassfish admin console with: https://localhost:8x48 (the x needs to be replaced)
- 8048: web-domain, 8148: store-domain, 8248: adapter-domain, 8348: enterprise-domain, 8448: registry-domain
- choose *server (Admin server)* > *View Log Files* or *View Raw Log*


# Implementation details & reasons

### Dockerfile

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

### startdomain.sh
- if statement at the beginning
 -> When we  restart (stop and start) a docker container, we only need to start the domains again (without create and set passwords etc.). We used this workaround, as docker has no command for docker start with certain script. *docker start* automatically runs the startdomain.sh within the CMD command but this will start the whole process of password setting again. So, at the beginnig of startdomain.sh we ask the container wether it already created the passwordfile (this implicates that the container was already started at least one time) or not.

- adding password files and enabling secure admin
    -> Glassfish requires an enabled secure admin when executed in a docker environment. This needs a password file added to the domains (default: no password when domains were created)

- cloning the cocome repository 
 -> the purpose of this project has been to create an docker file which installs the most recent version of cocome into a container. By cloning the repository within the CMD call, the cloning process starts when the container is about to be created.
- last command in script is executed in --verbose mode
    -> Docker stops if no application is running foreground. As glassfish runs in background, the container would stop if the script is executed completely. So we decided to choose this workaround: the last domain is restarted in verbose mode, so glassfish enters the console and pretends to run foreground. Sadly there's one bad side effect: No command can be executed beyond this point. Maybe there's another solution which we did not find so far.
    
### restart.sh
-this script gets executed only if the glassfish setup (password, enabling secure-admin etc) was executed before. In other words, this script is used when we restart a stopped container. 
    
# Problems which are not resolved so far

- So far, it is possible to restart a container when it got stopped correctly. But for some reason, CoCoME doesn't work anymore. This actually happened before, when we stopped and started glassfish within eclipse. To solve this problem, we did mvn clean post-clean install and mvn package again, deleted some cache files and undeployed the .war/.ear files by hand. This will be impossible to do within a console so maybe restarting a container with CoCoME will not work -> *docker run...* will have to be executed again, which also causes a loss of the database.
-> Problem found: the glassfish domains have to be started in a preassigned order:  start database, start registry, start adapter, start the rest
	
	

