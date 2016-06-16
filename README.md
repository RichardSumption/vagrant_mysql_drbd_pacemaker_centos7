#vagrant_mysql_drbd_pacemaker_centos7

# Simple Description

Still a 'work in progress' to make it a generic build.
At present it will create the cluster and start everything,
but at the moment it is fixed to the ip's defined.  



### Simple 2-Node Mysql cluster on Centos7
Built with Vagrant and virtualbox
and incorporating Puppet, DRBD, MySQL, Pacemaker & Corosync  



## Defaults ip addresses:  
   virtual_ip - 192.168.56.10
   node01     - 192.168.56.11
   node02     - 192.168.56.12
