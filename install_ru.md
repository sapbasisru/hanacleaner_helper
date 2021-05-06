Инсталляция скрипта HANACleaner
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

Подготовить папку для исполняемых файлов
----------------------------------------

В простых случаях для размещения исполняемых файлов можно использовать
локальную папку `/opt/hanacleaner`.
Возможно, для scale-out конфигураций HANA, более простым в экслуатации решением 
будет использование общей для всех узлов HANA папки, например, 
`/usr/sap/${SAPSYSTEMNAME}/SYS/global/hdb/custom/python_support`

В папку исполняемых файлов необходимо разместить
скрипт-исполнитель `opt/hanacleaner-starter.sh`
и python-скрипт HANACleaner `hanacleaner.py`.

Для доступа администраторов ОС HANA к сриптам необходимо установить группу `sapsys` для папки и файлов и маску прав 755.

```sh
mkdir /opt/hanacleaner
cp opt/hanacleaner_starter.sh /opt/hanacleaner
cp ${HANALCEANER_FOLDER}/hanacleaner.py /opt/hanacleaner
chgrp -R sapsys /opt/hanacleaner
chown 755 /opt/hanacleaner /opt/hanacleaner/hanacleaner_helper.sh
```

Подготовить папку конфигурационных файлов
-------------------------------------------

Стандартной папкой размещения конфигурационных файлов для скрипта-исполнителя
является `/etc/opt/hanacleaner`. 

В подготовленную папку скопировать конфигурационные шаблоны из `etc/opt`. На текущий момент доступны следующие шаблоны:
- template_housekeeping.conf - шаблон задачи автоматической периодической очистки БД HANA.
- template_release_logs.conf - шаюлон залачи очичтик свободных журнальных файлов БД HANA.

Для доступа администраторов ОС HANA к конфигурационным файлам необходимо установить группу `sapsys` для папки и файлов. 
Для папки установить маску прав 775, для файлов - 664.



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
