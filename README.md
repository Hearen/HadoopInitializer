## HadoopInitializer
-----

This collection of scripts are used to automate the installing and configuring hadoop 2.7
in a cluster composed of a certain amount of hosts connected to one another, by providing the least amount of manual information, dramatically reducing the effort of the hadoop configuration in a set of hosts. During the whole installation and configuration process, all the user need to do is provide all the IP addresses of the hosts, input the password for each host when prompted, customize the hadoop xml configuration files with the assistance of the hint from the program and that's all, quite simple and convenient now to configure a hadoop cluster.

Of course there are still many aspects that can be further optimized including the following parts: fault-tolerance, portability and maintainability; 
- as for fault-tolerance, all the program does is to prompt the failure and essential debugging information if one stage failed but it cannot roll back to the previous stage; 
- for portability, the operating system is fixed on the CentOS 7.1, after some checking some inconsistency among different systems in some operations are quite different so it's quite uneasy to make this program run in another system;  
- when it comes to maintainability, the jdk 1.8 and hadoop 2.7 are both hard-coded which means when encountering different versions there will be different configuration processes, the whole program can be invalid but of course still parts of the program can be used to assist and guide the user to complete the configuration.

Features
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

Follow-up
------------------

- before installing and configuring, the program will try to check it first to avoid another redundant installation and configuration;
- all the features are arranged in separate functions which will reduce the difficulty to understand the inner thread and increase its readability and reusability;
- critical comments are enclosed to provide as much clue as possible, besides the issues of this repository will also be helpful when encountering some problems;
- to measure the network distance among hosts, there is also a small script enclosed to check the `ping` distance among hosts - [A to B] is not the same as [B to A];

To be added
---------------

- a simple guide should be enclosed to use this program which should cover the basic and some advanced usage;
- currently the program will prompt the user to input many repeated redundant information to proceed which can be handled by `expect` easily;
- the format and interactive information can be misleading sometimes, so it's quite necessary to further test it and update them;

Usage
-----
1. git clone https://github.com/Hearen/HadoopInitializer.git
2. cd HadoopInitializer
3. su
4. ./install.sh
and then just follow the hints of the program, good luck!

Support
-------

There are lots of issues that might occur during the configuration and also some brilliant tools that might be helpful.

#### about hadoop
* stop-all.sh #to stop all the hadoop service;
* start-all.sh #to start the hadoop service;
* hdfs dfsadmin -report #to report the status of the cluster which is quite the same as opening a browser and access `$ip_address:50070`
* hdfs dfsadmin -safemode leave #leave the safe mode to avoid some checking and restriction which might cause some errors in testing
* hadoop fs -ls / #to list the files in the root directory of hdfs
* hadoop fs namenode -format #format the whole hdfs file system which is frequently used to correct some errors

#### about cgroup
* yum install libcgroup\* #to install cgroup in CentOS 7.1
* systemctl start cgconfig && systemctl enable cgconfig
* systemctl start cgred && systemctl enable cgred

edit the /etc/cgconfig.conf as follows
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

as for the major and minor number of the block device, we can use `ls -l /dev/` to retrieve it easily.

then edit /etc/cgrules to apply the rules defined in /etc/cgconfig.conf as follows:

```
hadoop blkio,cpu,memory hadoop/ 
```

then the user of hadoop will be limited in blkio, cpu and memory as defined in /etc/cgconfig.conf; in then end, we need to restart cgconfig and cgred to make the rules take effect instantly.
There is a good [reference](https://www.digitalocean.com/community/tutorials/how-to-limit-resources-using-cgroups-on-centos-6) for cgroup.

#### stress
Used to take over resources of the machine to cooperate with the cgroup to control the CPU performance for a user. If you intend to limit the CPU by cgroup, sadly you will fail considering it only takes cpu.shares into account which means if there are no other processes consuming the CPU the CPU then will be all used by current user. [Here](http://blog.scoutapp.com/articles/2014/11/04/restricting-process-cpu-usage-using-nice-cpulimit-and-cgroups) is good post to clarify this kind of issue. 
To install `stress`, you have to configure epel repository first by `yum install epel-release` as epel-release you may check this [post](http://www.tecmint.com/how-to-enable-epel-repository-for-rhel-centos-6-5/).
three most important commands in this tool: 
* uptime #check the usage of the CPU
* watch uptime #continually update the statistics output from uptime
* stress -c 2 -i 1 -m 1 --vm-bytes 128M -t 10s #run 2 cpu intensive, 1 network intensive and 1 memory intensive works respectively

If encountering some problems installing `stress`: 
1. 'install epel-release' first and then refresh 'yum install repolist' and then `yum install stress`;
2. install it manually `wget http://apt.sw.be/redhat/el7/en/x86_64/rpmforge/RPMS/stress-1.0.2-1.el7.rf.x86_64.rpm` and then `rpm -ivh stress-1.0.2-1.el7.rf.x86_64.rpm`

#### other useful commands
* top -u $user_name #check the resources usage of specific user
* free -h #check the memory of the machine
* whoami #similar to `echo $USER` to check the current user
* netstat -tulpn #check which process is taking the port
* watch #used to run certain program continually
* groups $user_name #to check the groups to which the user belongs
* usermod -aG wheel $user_name #to enable the sudo for the user
* hdparm --direct -t /dev/sda #to check the writing speed in the disk, if unavailable, install it first
* dd if=/dev/zero of=./test0.img bs=1G count=40 #to create a 40G size empty file which can be used as virtual disk

#### some benchmarks
pi 
* hadoop jar /home/hadoop/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.1.jar pi 16 1000

There is a nice detailed post about [TestDFSIO](hadoop jar /home/hadoop/hadoop-2.7.1/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.7.1-tests.jar TestDFSIO -read -nrFiles 64 -fileSize 16GB -resFile /tmp/TestDFSIOwrite.txt).
* hadoop jar /home/hadoop/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-27.1-tests.jar TestDFSIO -write -nrFiles 64 -fileSize 16MB -resFile /tmp/TestDFSIOwrite.txt`
* hadoop jar /home/hadoop/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.7.1-tests.jar TestDFSIO -read -nrFiles 64 -fileSize 16GB -resFile /tmp/TestDFSIOwrite.txt`

terasort
* hadoop jar /home/hadoop/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.1.jar teragen 5000000 terasort-input
* hadoop jar /home/hadoop/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.1.jar terasort terasort-input terasort-output
* hadoop jar /home/hadoop/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.1.jar teravalidate terasort-output terasort-validate

#### some typical issues
1. inconsistency clusterID among namenode and datanode: just stop it first,  delete all the tmp directories in all hosts including master and slave and then format the hdfs and at last start the cluster again and check it by `hdfs dfsadmin -report`;
2. check the ssh-login-without-password among hosts and ensure the firewall and selinux mode are all shut down and disabled which might result in some datanodes un-reachable or invalid in the cluster;
3. check if you are in safe mode and shut it down by `hdfs dfsadmin -safemode leave`; 
4. still not working, check the logs in namenode and datanode using `ls -t` in $HADOOP_HOME/logs and you can easily check the latest log of the namenode or datanode which should be helpful for debugging.

Contribution
----------
1. Fork it.
2. Create a branch (git checkout -b my_markup)
3. Commit your changes (git commit -am "Added Snarkdown")
4. Push to the branch (git push origin my_markup)
5. Open a Pull Request in the repository web page
6. Enjoy a refreshing Diet Coke and carry on with your own stuff

### Contact
- Author: LHearen
- E-mail: LHearen@gmail.com   
- Created: Fri, 2016-05-06 09:18
