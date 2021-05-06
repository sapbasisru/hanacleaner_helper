Installation of the HANACleaner 
===============================

Download or clone HANACleaner repository
----------------------------------------
You need clone or donwload the HANACleaner repository into a separate folder.
You can clone HANACleaner with the `git` command or you can use another way to get this repository.
```sh
git clone https://github.com/sapbasisru/hanacleaner hanacleaner.git
```

In the future I will point the folder to HANACleaner repository with variable `__HANALCEANER_FOLDER`.
```sh
HANALCEANER_FOLDER = ../hanacleaner.git
```

Prepare binary folder
---------------------

The simplest way is put the executable file hanacleaner_helper.sh into common local directory, 
for example into `/opt/hanacleaner`. You can place HANAClenaer both as 
into `/opt/hanacleaner` and 
into `/usr/sap/${SAPSYSTEMNAME}/SYS/global/hdb/custom/python_support`
for example.

```sh
mkdir /opt/hanacleaner
cp opt/hanacleaner_helper.sh /opt/hanacleaner
cp ${HANALCEANER_FOLDER}/hanacleaner.py /opt/hanacleaner
chgrp -R sapsys /opt/hanacleaner
chown 775 /opt/hanacleaner /opt/hanacleaner/hanacleaner_helper.sh
```

Prepare configuration folder
----------------------------

Prepare log folder
------------------


Create folder strusture
-----------------------
Create folders for binary files:
Create folders for configuration files:
```sh
mkdir /etc/opt/hanacleaner
```

Create folders for log files:
```sh
mkdir /var/opt/hanacleaner
```

Copy the files to folders
-------------------------
Copy the HANACleaner script:
```sh
```
Copy the HANACleaner heler script:
```sh
cp opt/bin/hanacleaner.sh /opt/hanacleaner/bin
```

Set permisssions and ownership for folders and files
----------------------------------------------------
Set group sapsys and permissions to any folders and files of the packet.
```sh
chgrp -R sapsys /opt/hanacleaner /etc/opt/hanacleaner /var/opt/hanacleaner
chmod -R 775 /opt/hanacleaner /opt/hanacleaner/bin /opt/hanacleaner/python
chmod -R 664 /etc/opt/hanacleaner /var/opt/hanacleaner
```
