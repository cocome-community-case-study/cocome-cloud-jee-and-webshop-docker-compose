#With-Maven-attempt

- The aim of this branch, was to get a running instance of CoCoME in one container and a running instance of the Webshop in another. Both containers should be able to communicate with each other, so that the Webshop could be used as usual. "As usual" in this case means: CoCoME and Webshop running on one local machine without any troubles.
- The main aspect: During docker build/run, the newest version of CoCoME and Webshop should get pulled from the Git Repository.
- On the master branch, there is already a vesion that's using a static version. That means, CoCoME does not get updated unless somebody exchanges the deployable .war/.jar-Files by hand.


#Background
We tried to use the approach that has been applied in this [Repo](https://github.com/cocome-community-case-study/cocome-cloud-jee-docker.git): 
- Using git to get the newest version of CoCoME
- Using mvn install with given settings to compile, package an deploy the webshop and CocoME within the two containers.

#Problems
- The webshop depends on a previos installed version of CoCoME on the same machine: It needs some maven dependencies which would be present, if CoCoME ha been installes before.
- As we install CoCoME on a different machine (different container = different machine), the Webshop cannot find those dependecies and tries to download them from a public maven repo, where they do not exist.
- --> mvn install in Webshop container fails

#Solution statement
- Copy needed code from CoCome into Webshop  --> not a really satisfiying solution
- Only integrate ApplicationHelper so that the WebShop is using those Dependencies through registry --> Seems to be a lot of work. FOR NOW, that's the reason not to continue working on this Project.