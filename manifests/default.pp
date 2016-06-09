node 'node02' {
   include cluster_prep
   include drbd_install_slave
}

node 'node01' {
   include cluster_prep
   include drbd_install_master
   include mysql_setup
   include pacemaker_config
}
