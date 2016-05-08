## HadoopInitializer
-----

The collection of all the scripts are used to configure the working 
environment of hadoop in CentOS 7.1 including all the following aspects:

- check the permission of the current role;
- check the network and try to fix it if not available;
- add working user, set its password and add it sudoers for later hadoop use;
- according to a file containing all the ips of the hosts to change the hostnames and then add all the new hostnames in the hadoop cluster to /etc/hosts of all hosts;
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
