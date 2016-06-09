class drbd_install_slave {
   require cluster_prep

   Exec {
      path        => ['/bin', '/sbin', '/usr/bin'],
      logoutput   => 'on_failure',
   }

   file { '/var/lib/mysql_drbd':
      ensure => 'directory',
      owner => 'mysql',
      group => 'mysql',
      require => Class['cluster_prep'],
   }

   file { '/etc/drbd.conf':
      source => 'puppet:///modules/cluster_prep/drbd.conf',
   }

   exec { 'drbd_create':
      command => '/bin/echo "yes" | /usr/sbin/drbdadm create-md r0',
      creates => '/var/run/drbd/drbd-resource-r0.conf',
      require => File['/etc/drbd.conf'],
   }

   service { 'drbd':
      ensure => running,
      enable => false,
      require => Exec['drbd_create'],
   }
}
