#HadoopInitializer

#####################################################################################
#Author      : LHearen
#E-mail      : LHearen@gmail.com
#Time        : Fri, 2016-05-06 09:18
#Description : The collection of all the scripts are used to configure the working 
#              environment of hadoop in CentOS 7.1 including all the following steps:
#####################################################################################

## Outline
------

- check the permission of the current role;
- check the network and try to fix it if not available;
- add working user and set its password for later hadoop use;
- change the hostname and then add all the new hostnames in the hadoop cluster to /etc/hosts;
- enable login via ssh without password;
- download jdk 1.8 and configure its environment variables;
- download hadoop 2.7 and configure its environment variables;
- activate the newly added environment variables and check its validity;
- update the xml configuration files for hadoop cluster;
- start hadoop in master node and check its status in each node in the cluster;

