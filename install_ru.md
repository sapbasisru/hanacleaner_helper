Инсталляция скрипта HANACleaner
===============================

Загрузить Git-репозитарии 
--------------------------

Для работы с HANACleaner потребуется загрузить два репозитария с GitHub:
- `https://github/sapbasisru/hanacleaner.git` - репозитарий, содержащий python-скрипт HANACleaner (`hanacleaner.py`)
- `https://github/sapbasisru/hanacleaner_helper.git` - репозитарий, содержащий скрипт-исполнитель и подготовленные конфигурационные файлы.

Загрузить репозиатрий можно либо с помощью команды `git clone` или другими средствами.

В дальнейшем будет полагать, что локальные копии репозитариев скопированы в папки `$HC_DIR` и `$HCH_DIR` соответственно.

Подготовить папку для исполняемых файлов
----------------------------------------

В простых случаях для размещения исполняемых файлов можно использовать
локальную папку `/opt/hanacleaner`.
Возможно, для scale-out конфигураций HANA, более простым в экслуатации решением 
будет использование общей для всех узлов HANA папки, например, 
`/usr/sap/${SAPSYSTEMNAME}/SYS/global/hdb/custom/python_support`

В папку исполняемых файлов необходимо разместить:
- python-скрипт HANACleaner `hanacleaner.py` и
- скрипт-исполнитель `opt/hanacleaner-starter.sh`.

Для доступа администраторов ОС БД HANA к сриптам необходимо установить группу `sapsys` для папки и файлов и маску прав 755.

```sh
[[ test -d /opt/hanacleaner ]] || mkdir /opt/hanacleaner
cp $HC_DIR/hanacleaner.py /opt/hanacleaner
cp $HCH_DIR/opt/hanacleaner_starter.sh /opt/hanacleaner
chgrp -R sapsys /opt/hanacleaner
chown 755 /opt/hanacleaner /opt/hanacleaner/hanacleaner_helper.sh
```

Подготовить папку конфигурационных файлов
-------------------------------------------

По умолчанию скрипт-исполнитель для чтения конфигурационных файлов использует папку
`/etc/opt/hanacleaner`. 
Можно использовать другую папку для конфигурационных файлов. 
Нестандартное расположение папки задается с помощью опции `--config-dir` при старте скрипта-исполнителя.

Из папки `etc/opt` в подготовленную папку скопировать шаблоны конфигурационных файлов для типовых задачи. На текущий момент доступны следующие шаблоны:
- `template_housekeeping.conf` - шаблон задачи автоматической периодической очистки БД HANA.
- `template_release_logs.conf` - шаюлон задачи очистки свободных журнальных файлов БД HANA.

Для доступа администраторов ОС БД HANA к конфигурационным файлам необходимо установить группу `sapsys` для папки и файлов. 
Для папки установить маску прав 775, для файлов - 664.

```sh
[[ -d /etc/opt/hanacleaner ]] || mkdir /etc/opt/hanacleaner
cp $HCH_DIR/etc/opt/template_housekeeping.conf /etc/opt/hanacleaner
cp $HCH_DIR/etc/opt/template_release_logs.conf /etc/opt/hanacleaner
chgrp -R sapsys /etc/opt/hanacleaner
chown 775 /etc/opt/hanacleaner
chown 664 /etc/opt/hanacleaner/*
```

Подготовить папку журналов работы
---------------------------------

Для записи журналов работы скрипт-исполнитель использует папку /var/opt/hanaleaner.
Можно использовать другую папку для записи журналов.
Нестандартное расположение папки задается с помощью опции `--log-dir` при старте скрипта-исполнителя.

```sh
[[ -d /var/opt/hanacleaner ]] || mkdir /var/opt/hanacleaner
chgrp -R sapsys /var/opt/hanacleaner
```
