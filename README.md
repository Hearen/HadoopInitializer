## HadoopInitializer

This collection of scripts are used to assist to automate the installation and configuration of hadoop 2.7
in a cluster composed of a certain amount of hosts connected to one another, by providing the least amount of manual information, dramatically reducing the effort of the hadoop configuration in a set of hosts. 

> During the whole installation and configuration process, all the user need to do is provide all the IP addresses of the hosts, input the password for each host when prompted, customize the hadoop xml configuration files with the assistance of the hint from the program and that's all, quite simple and convenient now to configure a hadoop cluster.

Features
--------
- check the permission of the current role;
- check the network and try to fix it if not available;
- add working user, set its password and add it to sudoers for later sudo command;
- change the hostnames and then update /etc/hosts for all hosts;
- enable login via ssh without password among hosts in the cluster;
- shut down selinux and firewall of the hosts for easy connections among hosts;
- download jdk 1.8 and configure java, javac and jre locally;
- download hadoop 2.7 and install it locally;
- according to the user to update the java and hadoop environment variables;
- configure and activate the newly java and hadoop environment variables for all the hosts;
- start hadoop in master node and check its status in each node in the cluster;

Follow-up
------------------
Some auxiliary features are well accomplished to make this program more readable, robust and maintainable.
- before installing and configuring, the program will try to check it first to avoid another redundant installation and configuration;
- all the features are arranged in separate functions which will reduce the difficulty to understand the inner thread and increase its readability and reusability;
- critical comments are enclosed to provide as much clue as possible, besides the issues of this repository will also be helpful when encountering some problems;

Usage
-----
1. git clone https://github.com/Hearen/HadoopInitializer.git
2. cd HadoopInitializer
3. cd etc 
4. insert the IP addresses of the hosts into [ip_addresses](etc/ip_addresses) in different lines
5. cd ../hadoop
6. configure the XML files as each hadoop cluster configuration does in [core-site.xml](hadoop/core-site.xml), [hdfs-site.xml](hadoop/hdfs-site.xml), [mapred-site.xml](hadoop/mapred-site.xml), [master](hadoop/master) and [slaves](hadoop/slaves); as for master you only need to input *hadoop-master* while slaves will be inserted with all the slaves' new hostnames from hadoop-slave1, hadoop-slave2 to hadoop-slaveX, **X** here refers to the amount of the slaves in the cluster;
7. cd ../tools
8. ./clear_walls.sh #shut down and disable the firewall and selinux mode for all hosts, there will be a rebooting, so just be patient and have a bottle of iced beer
9. su #after rebooting, log in the master and gain root privilege
10. ./install.sh 

and then just follow the program, good luck!

Support
-------
This part will cover the enclosed assistant scripts in tools, basic hadoop commands, cgroup configuration and usage,  stress used to control the CPU utilization, some useful Linux commands and the benchmarks used widely.

#### tools
There are lots of issues that might occur during the configuration, so there are some convenient tools that might be helpful when encountering some problems. 
- [clear_walls.sh](tools/clear_walls.sh) used to shut down firewall and selinux mode of the hosts
- [cgroup_configurer.sh](tools/cgroup_configurer.sh) used to configure the cgroup of course before which you are required to set up the configuration files [cgconfig.conf](etc/cgconfig.conf) and [cgrules.conf](etc/cgrules.conf)
- [distance_checker.sh](tools/distance_checker.sh) used to check the `ping` network distance among hosts
- [transfer.sh](tools/transfer.sh) which is to use [ips_file](tools/etc/ips_file) to transfer scripts to configure the host accordingly
- [traffic_controller.sh](tools/traffic_controller.sh) is to take advantage of [tc](http://lartc.org/manpages/tc.txt) to throttle the maximum network rate of certain host
- [logout.sh](tools/logout.sh) used to log out the account of ISCAS internal network
- [login.sh](tools/login.sh) used to log in the ISCAS internal network with a certain account 

#### hadoop
Some frequently used commands in hadoop cluster management, for more detailed information you might need to check its [official site](https://hadoop.apache.org/docs/r2.7.1/).
* stop-all.sh #to stop all the hadoop service;
* start-all.sh #to start the hadoop service;
* hdfs dfsadmin -report #to report the status of the cluster which is quite the same as opening a browser and access `$master_ip_address:50070`
* hdfs dfsadmin -safemode leave #leave the safe mode to avoid some checking and restrictions which might cause some errors in testing
* hadoop fs -ls / #to list the files in the root directory of hdfs, [more](https://hadoop.apache.org/docs/r2.7.1/hadoop-project-dist/hadoop-common/FileSystemShell.html#mkdir)
* hadoop fs namenode -format #format the whole hdfs file system which is frequently used to correct some errors

#### cgroup
There is a [cgroup_configurer.sh](tools/cgroup_configurer.sh) in tools directory which can help you a little bit for cgroup configurations as for details you might intend to check the details as follows:
* yum install libcgroup\* #to install cgroup in CentOS 7.1
* systemctl start cgconfig && systemctl enable cgconfig
* systemctl start cgred && systemctl enable cgred

Edit the /etc/cgconfig.conf as follows
```
group hadoop
{
    cpu {
cpu.shares = 400;
    }
    memory {
memory.limit_in_bytes = 1024m;
    }
    blkio {
blkio.throttle.read_bps_device = “8:0 209715”; 
    }
}
```

As for the major and minor number of the block device, we can use `ls -l /dev/` to retrieve it easily.

Then edit /etc/cgrules to apply the rules defined in /etc/cgconfig.conf as follows:

```
hadoop blkio,cpu,memory hadoop/ 
```

Now the user of hadoop will be limited in blkio, cpu and memory as defined in /etc/cgconfig.conf; in the final end, we need to restart cgconfig and cgred to make the rules take effect instantly.
There is a good [reference](https://www.digitalocean.com/community/tutorials/how-to-limit-resources-using-cgroups-on-centos-6) for cgroup.

#### stress
Used to take over CPU resources of the machine to cooperate with the cgroup to control the CPU performance for a user. If you intend to limit the CPU only by cgroup, sadly you will fail considering it only takes cpu.shares into account which means if there are no other processes consuming the CPU the CPU then will be all used by current user. [Here](http://blog.scoutapp.com/articles/2014/11/04/restricting-process-cpu-usage-using-nice-cpulimit-and-cgroups) is good post to clarify this kind of issue. 

To install `stress`, you have to configure epel repository first by `yum install epel-release`. As for epel-release you may want to check this [post](http://www.tecmint.com/how-to-enable-epel-repository-for-rhel-centos-6-5/) for further understanding.

Three most frequently used commands of `stress`: 
* uptime #check the usage of the CPU
* watch uptime #continually update the statistics output from uptime
* stress -c 2 -i 1 -m 1 --vm-bytes 128M -t 10s #run 2 cpu intensive, 1 network intensive and 1 memory intensive workers respectively

If encountering some problems when installing `stress`: 

1. `install epel-release` first, refresh the repolist by `yum install repolist` and then `yum install stress`;
2. install it manually `wget http://apt.sw.be/redhat/el7/en/x86_64/rpmforge/RPMS/stress-1.0.2-1.el7.rf.x86_64.rpm` and then `rpm -ivh stress-1.0.2-1.el7.rf.x86_64.rpm`

#### Some useful commands
* top -u $user_name #check the resources usage of specific user
* free -h #check the memory of the machine
* whoami #similar to `echo $USER` to check the current user
* netstat -tulpn #check which process is taking the port
* watch #used to run certain program continually
* groups $user_name #to check the groups to which the user belongs
* usermod -aG wheel $user_name #to enable the sudo for the user
* hdparm --direct -t /dev/sda #to check the writing speed in the disk, if unavailable, install it first
* dd if=/dev/zero of=./test0.img bs=1G count=40 #to create a 40G size empty file which can be used as virtual disk

#### Benchmarks
There are lots of built-in benchmarks which we can find in hadoop `hadoop jar /home/hadoop/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.1` or `hadoop jar /home/hadoop/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-27.1-tests.jar`but as for the most popular ones, they will be CPU intensive type - **pi**, I/O intensive - **TestDFSIO** and integrated and the most popular - **terasort**. 

pi - CPU intensive type
* hadoop jar /home/hadoop/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.1.jar pi 16 1000

TestDFSIO - I/O intensive type
* hadoop jar /home/hadoop/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.7.1-tests.jar TestDFSIO -write -nrFiles 64 -fileSize 16MB -resFile /tmp/TestDFSIOwrite.txt
* hadoop jar /home/hadoop/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.7.1-tests.jar TestDFSIO -read -nrFiles 64 -fileSize 16GB -resFile /tmp/TestDFSIOwrite.txt

For more additional details about this benchmark, you may want to check [this](hadoop jar /home/hadoop/hadoop-2.7.1/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.7.1-tests.jar TestDFSIO -read -nrFiles 64 -fileSize 16GB -resFile /tmp/TestDFSIOwrite.txt);

terasort
* hadoop jar /home/hadoop/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.1.jar teragen 5000000 terasort-input
* hadoop jar /home/hadoop/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.1.jar terasort terasort-input terasort-output
* hadoop jar /home/hadoop/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.1.jar teravalidate terasort-output terasort-validate

#### Typical issues
There are some issues which can be tricky for newbies in hadoop that I met myself and solved with the following steps. I hope they might ease some labor of your searching.

1. inconsistency clusterID among namenode and datanode: just stop it first,  delete all the tmp directories in all hosts including master and slave and then format the hdfs and at last start the cluster again and check it by `hdfs dfsadmin -report`;
2. check the ssh-login-without-password among hosts and ensure the firewall and selinux mode are all shut down and disabled which might result in some datanodes un-reachable or invalid in the cluster;
3. when it only comes to the `JAVA_HOME is not set` problem, just hard code it in HADOOP_HOME/etc/hadoop/hadoop-env.sh and then re-run the `install.sh` and select the `Copy hadoop configuration files for hadoop cluster`.
4. check if you are in safe mode and shut it down by `hdfs dfsadmin -safemode leave`; 
5. still not working, check the logs in namenode and datanode using `ls -t` in $HADOOP_HOME/logs and you can easily check the latest log of the namenode or datanode which should be helpful for debugging;

To be updated
---------------
There are several quite specific flaws that can be fixed as follows:
- a simple guide should be enclosed to use this program which should cover the basic and some advanced usage;
- currently the program will prompt the user to input many repeated redundant information to proceed which can be handled by [expect](http://expect.sourceforge.net) easily;
- the format and interactive information can be misleading sometimes, so it's quite necessary to further test it and update them;

Of course there are still many aspects that can be further optimized including the following parts: fault-tolerance, portability and maintainability; 
- as for fault-tolerance, all the program does is to prompt the failure and essential debugging information if one stage failed but it cannot roll back to the previous stage; 
- for portability, the operating system is fixed on the CentOS 7.1, there are some inconsistency among different systems in some critical operations so it's quite uneasy to make this program run in another system;  
- when it comes to maintainability, the jdk 1.8 and hadoop 2.7 are both hard-coded which means when encountering different versions there will be different configuration processes, the whole program can be invalid but of course still parts of the program can be used to assist and guide the user to complete the configuration.



Contribution
----------
1. Fork it.
2. Create a branch (git checkout -b my_branch)
3. Commit your changes (git commit -am "fix some serious issues in configuring hadoop locally")
4. Push to the branch (git push origin my_branch)
5. Open a Pull Request in web page of the forked repository 
6. Enjoy a refreshing Diet Coke and carry on with your own stuff

### Contributor
- Author: LHearen
- E-mail: LHearen@gmail.com   
- Created: Fri, 2016-05-06 09:18

### License
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version. See [LICENSE](LICENSE) for more details.
