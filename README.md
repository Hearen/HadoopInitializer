## HadoopInitializer
-----

This collection of scripts are used to automate the installing and configuring hadoop 2.7
in a cluster composed of a certain amount of hosts connected to one another, by providing the least amount of manual information, dramatically reducing the effort of the hadoop configuration in a set of hosts. During the whole installation and configuration process, all the user need to do is provide all the IP addresses of the hosts, input the password for each host when prompted, customize the hadoop xml configuration files with the assistance of the hint from the program and that's all, quite simple and convenient now to configure a hadoop cluster.

Of course there are still many aspects that can be further optimized including the following parts: fault-tolerance, portability and maintainability; 
- as for fault-tolerance, all the program does is to prompt the failure and essential debugging information if one stage failed but it cannot roll back to the previous stage; 
- for portability, the operating system is fixed on the CentOS 7.1, after some checking some inconsistency among different systems in some operations are quite different so it's quite uneasy to make this program run in another system;  
- when it comes to maintainability, the jdk 1.8 and hadoop 2.7 are both hard-coded which means when encountering different versions there will be different configuration processes, the whole program can be invalid but of course still parts of the program can be used to assist and guide the user to complete the configuration.

Achieved
--------

- check the permission of the current role;
- check the network and try to fix it if not available;
- add working user, set its password and add it to sudoers for later sudo command;
- change the hostnames and then update /etc/hosts for all hosts;
- enable login via ssh without password among hosts in the cluster;
- shut down selinux and firewall of the hosts for easy connections among hosts in the cluster;
- download jdk 1.8 and configure java, javac and jre locally;
- download hadoop 2.7 and install it locally;
- according to the user to update the java and hadoop environment variables;
- configure and activate the newly java and hadoop environment variables for all the hosts;
- start hadoop in master node and check its status in each node in the cluster;

Considerate points
------------------

- before installing and configuring, the program will try to check it first to avoid another redundant installation and configuration;
- all the features are arranged in separate functions which will reduce the difficulty to understand the inner thread and increase its readability and reusability;
- critical comments are enclosed to provide as much clue as possible, besides the issues of this repository will also be helpful when encountering some problems;
- to measure the network distance among hosts, there is also a small script enclosed to check the `ping` distance among hosts - [A to B] is not the same as [B to A];

To be continued
---------------

- a simple guide should be enclosed to use this program which should cover the basic and some advanced usage;
- currently the program will prompt the user to input many repeated redundant information to proceed which can be handled by `expect` easily;
- the format and interactive information can be misleading sometimes, so it's quite necessary to further test it and update them;

### Contact

- Author: LHearen
- E-mail: LHearen@gmail.com   
- Created: Fri, 2016-05-06 09:18
