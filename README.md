# checkDup
Check duplicate files in directories (recursively)

Usage:

**$ ./checkDup.pl -d /home/jsl/Downloads/**

* Search duplicates in /home/jsl/Downloads/ ...
*** Check /home/jsl/Downloads/aide-0.15.1.tar.gz ...
*** Check /home/jsl/Downloads/subdir_02/newname.tar.gz ...
*** Check /home/jsl/Downloads/subdir_01/aide-0.15.1.tar.gz ...

============== Duplicate files ============== 
* d0b72535ff68b93a648e4d08b0ed7f07:
====> /home/jsl/Downloads/subdir_01/aide-0.15.1.tar.gz
====> /home/jsl/Downloads/aide-0.15.1.tar.gz
====> /home/jsl/Downloads/subdir_02/newname.tar.gz
* Size of duplicate files: 830.02 KB
* END

--------------------------------------------------------------------

**$ ./checkDup.pl -d /home/jsl/Downloads/ -e /home/jsl/Downloads/subdir_02**

* Search duplicates in /home/jsl/Downloads/ ...
*** Check /home/jsl/Downloads/aide-0.15.1.tar.gz ...
*** Check /home/jsl/Downloads/subdir_01/aide-0.15.1.tar.gz ...

============== Duplicate files ============== 
* d0b72535ff68b93a648e4d08b0ed7f07:
====> /home/jsl/Downloads/aide-0.15.1.tar.gz
====> /home/jsl/Downloads/subdir_01/aide-0.15.1.tar.gz
* Size of duplicate files: 415.01 KB
* END

---------------------------------------------------------------------

**$ ./checkDup.pl -d /home/jsl/Downloads/ -e /home/jsl/Downloads/subdir_02 -g**

* Search duplicates in /home/jsl/Downloads/ ...
*** Check /home/jsl/Downloads/aide-0.15.1.tar.gz ...
*** Check /home/jsl/Downloads/subdir_01/aide-0.15.1.tar.gz ...

============== Duplicate files ============== 
* d0b72535ff68b93a648e4d08b0ed7f07:
(Preserved file: /home/jsl/Downloads/aide-0.15.1.tar.gz)
====> /home/jsl/Downloads/aide-0.15.1.tar.gz
====> /home/jsl/Downloads/subdir_01/aide-0.15.1.tar.gz

==> Generated script: /tmp/checkDupScript.sh
* Size of duplicate files: 415.01 KB
* END

$ more /tmp/checkDupScript.sh 
#!/bin/bash 

echo Removing "/home/jsl/Downloads/subdir_01/aide-0.15.1.tar.gz" ...
/usr/bin/rm -f "/home/jsl/Downloads/subdir_01/aide-0.15.1.tar.gz"
echo END
