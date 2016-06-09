resource r0 {
   protocol C;
   meta-disk internal;
   device /dev/drbd0;
   disk   /dev/sdb;
   net {
      allow-two-primaries no;
      after-sb-0pri discard-zero-changes;
      after-sb-1pri discard-secondary;
      after-sb-2pri disconnect;
      rr-conflict disconnect;
   }
   disk {
      on-io-error detach;
   }
   syncer {
      rate 40M;
   }
   on node01 {
      address  192.168.56.11:7788;
   }
   on node02 {
      address  192.168.56.12:7788;
   }
}
