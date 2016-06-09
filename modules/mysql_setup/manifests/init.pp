# Class to carry out the configuration of the mysql environment
class mysql_setup {
   require drbd_install_master

   Exec {
      path       => ['/bin', '/sbin', '/usr/bin'],
      user       => 'root',
      group      => 'root',
      logoutput  => 'on_failure',
   }

   exec { 'mysql_install':
      command => 'mysql_install_db --user=mysql --datadir=/var/lib/mysql_drbd/data',
      unless => 'test -d /var/lib/mysql_drbd/data/mysql',
      require => [ Class['drbd_install_master'], File['/var/lib/mysql_drbd/data'] ],
   }

   exec { 'drbd_umount':
      command     =>'umount /var/lib/mysql_drbd',
      onlyif      => "test `pcs status | grep Masters: | awk '{print $3}'` != \"node01\"",
      require => Exec['mysql_install']
   }
}
