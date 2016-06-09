class pacemaker_config {
   require mysql_setup

   Exec {
      path       => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
      user       => 'root',
      group      => 'root',
      logoutput  => 'on_failure',
   }

   exec { 'pcs_auth':
      command => 'pcs cluster auth node01 node02 -u hacluster -p CHANGEME --force',
      unless  => 'test -f /tmp/cluster_status',
      require => [ Exec['drbd_umount'], Class['mysql_setup'] ],
   }

   exec { 'pcs_setup':
      command => 'pcs cluster setup --name mysql_cluster node01 node02',
      creates => '/etc/corosync/corosync.conf',
      require => Exec['pcs_auth'],
   }

   exec { 'pcs_start':
      command => 'pcs cluster start --all',
      unless  => 'test -f /tmp/cluster_status',
      require => Exec['pcs_setup'],
   }

   exec { 'pcs_enable':
      command => 'pcs cluster enable --all',
      unless  => 'test -f /tmp/cluster_status',
      require => Exec['pcs_start'],
   }

   exec { 'pcs_stonith':
      command => 'pcs property set stonith-enabled=false',
      unless  => 'test -f /tmp/cluster_status',
      require => Exec['pcs_enable'],
   }

   exec { 'pcs_quorum':
      command => 'pcs property set no-quorum-policy=ignore',
      unless  => 'test -f /tmp/cluster_status',
      require => Exec['pcs_stonith'],
   }

   exec { 'pcs_sticky':
      command => 'pcs resource defaults resource-stickiness=200',
      unless  => 'test -f /tmp/cluster_status',
      require => Exec['pcs_quorum'],
   }

   exec { 'pcs_drbd1':
      command => 'pcs resource create p_drbd_mysql ocf:linbit:drbd drbd_resource=r0 op monitor interval=29s',
      unless  => 'test -f /tmp/cluster_status',
      cwd => '/vagrant',
      require => Exec['pcs_sticky'],
   }

   exec { 'pcs_drbd2':
      command => '/usr/sbin/pcs resource master ms_drbd_mysql p_drbd_mysql master-max=1 master-node-max=1 clone-max=2 clone-node-max=1 notify=true',
      unless  => 'test -f /tmp/cluster_status',
      cwd => '/vagrant',
      require => Exec['pcs_drbd1'],
   }

   exec { 'pcs_v_ip':
      command => '/usr/sbin/pcs resource create v_ip ocf:heartbeat:IPaddr2 ip=192.168.56.10 cidr_netmask=32 op monitor interval=30s',
      unless  => 'test -f /tmp/cluster_status',
      require => Exec['pcs_drbd2'],
   }

   exec { 'pcs_fs':
      command => '/usr/sbin/pcs resource create p_fs_mysql Filesystem device="/dev/drbd0" directory="/var/lib/mysql_drbd" fstype="ext4"',
      unless  => 'test -f /tmp/cluster_status',
      require => Exec['pcs_v_ip'],
   }

   exec { 'pcs_mysql':
      command => '/usr/sbin/pcs resource create p_mysql ocf:heartbeat:mysql binary="/usr/sbin/mysqld" config="/var/lib/mysql_drbd/my.cnf" datadir="/var/lib/mysql_drbd/data" pid="/var/lib/mysql/mysql.pid" socket="/var/lib/mysql/mysql.sock" user="mysql" group="mysql" additional_parameters="--bind-address=192.168.56.10 --user=mysql" op start timeout=120s op stop timeout=120s op monitor interval=20s timeout=30s',
      unless  => 'test -f /tmp/cluster_status',
      require => Exec['pcs_fs'],
   }

   exec { 'pcs_group':
      command => '/usr/sbin/pcs resource group add g_mysql p_fs_mysql v_ip p_mysql',
      unless  => 'test -f /tmp/cluster_status',
#      unless  => "test `pcs config | grep 'Group: g_mysql' | awk '{print $2}'` = \"g_mysql\"",
      require => Exec['pcs_mysql'],
   }

   exec { 'pcs_coloc':
      command => '/usr/sbin/pcs constraint colocation add ms_drbd_mysql g_mysql INFINITY with-rsc-role=Master',
      unless  => 'test -f /tmp/cluster_status',
#      unless  => "test `pcs config | grep 'colocation-ms_drbd_mysql-g_mysql' | awk '{print $1}'` = \"ms_drbd_mysql\"",
      require => Exec['pcs_group'],
   }

   exec { 'pcs_order':
      command => '/usr/sbin/pcs constraint order promote ms_drbd_mysql then start g_mysql',
      unless  => 'test -f /tmp/cluster_status',
#      unless  => "test `pcs config | grep 'order-ms_drbd_mysql-g_mysql' | awk '{print $2}'` = \"ms_drbd_mysql\"",
      require => Exec['pcs_coloc'],
   }

   $str="cluster built"
   file { '/tmp/cluster_status':
      content => $str,
      require => Exec['pcs_order'],
   }

}
