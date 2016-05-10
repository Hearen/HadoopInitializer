## HadoopInitializer
-----
This collection of scripts are used to automate the installing and configuring hadoop 2.7
in a cluster composed of a certain amount of hosts connected to one another, by providing the least amount of manual information, dramatically reducing the effort of the hadoop configuration in a set of hosts. During the whole installation and configuration process, all the user need to do is provide all the IP addresses of the hosts, input the password for each host when prompted, customize the hadoop xml configuration files with the assistance of the hint from the program and that's all, quite simple and convenient now to configure a hadoop cluster.

Of course there are still many aspects that can be further optimized including the following parts: fault-tolerance, portability and maintainability; 
- as for fault-tolerance, all the program does is to prompt the failure and essential debugging information if one stage failed but it cannot roll back to the previous stage; 
- for portability, the operating system is fixed on the CentOS 7.1, after some checking some inconsistency among different systems in some operations are quite different so it's quite uneasy to make this program run in another system;  
- when it comes to maintainability, the jdk 1.8 and hadoop 2.7 are both hard-coded which means when encountering different versions there will be different configuration processes, the whole program can be invalid but of course still parts of the program can be used to assist and guide the user to complete the configuration.

Most of the operations the program does:

- check the permission of the current role;
- check the network and try to fix it if not available;
- add working user, set its password and add it to sudoers for later hadoop use;
- according to a file containing all the ips of the hosts to change the hostnames and then add all the new hostnames in the hadoop cluster to /etc/hosts for all hosts;
- according to a file containing all the ips of the hosts to enable login via ssh without password among hosts in the cluster;
- download jdk 1.8 and configure java, javac and jre locally;
- download hadoop 2.7 and install it locally;
- according to a file containing all the ips of the hosts to configure and activate the newly java and hadoop environment variables;
- according to a file containing all the ips of the hosts to update the xml configuration files for each host of the hadoop cluster;
- start hadoop in master node and check its status in each node in the cluster;

### Contact
#####################################################################################
##### Author: LHearen
##### E-mail: LHearen@gmail.com   Time: Fri, 2016-05-06 09:18
#####################################################################################
