Инсталляция скрипта HANACleaner
===============================

Загрузить Git-репозитарии
--------------------------

Для работы с HANACleaner потребуется загрузить два репозитария с GitHub:

- `https://github.com/sapbasisru/hanacleaner.git` - репозитарий, содержащий python-скрипт HANACleaner (`hanacleaner.py`).
- `https://github.com/sapbasisru/hanacleaner_helper.git` - репозитарий, содержащий скрипт-исполнитель и подготовленные конфигурационные файлы.

Загрузить репозитарий можно либо с помощью команды `git clone` или другими средствами.

В дальнейшем предполагается, что переменные `HC_REPO_DIR` и `HCH_REPO_DIR` указывают на папки с локальными копиями репозитариев.

Скопировать/обновить репозитарий `hanacleaner.git`:

```bash
[[ -d $HC_REPO_DIR ]] || mkdir $HC_REPO_DIR
ls -ld $HC_REPO_DIR && \
    git clone https://github.com/sapbasisru/hanacleaner.git $HC_REPO_DIR
```

Скопировать/обновить репозитарий `hanacleaner_helper.git`:

```bash
[[ -d $HCH_REPO_DIR ]] || mkdir $HCH_REPO_DIR
ls -ld $HCH_REPO_DIR && \
    git clone https://github.com/sapbasisru/hanacleaner_helper.git $HCH_REPO_DIR
```

Подготовить папку для исполняемых файлов
----------------------------------------

В простых случаях для размещения исполняемых файлов можно использовать
локальную папку `/opt/hanacleaner`.
Возможно, для scale-out конфигураций HANA, более простым в экслуатации решением
будет использование общей для всех узлов HANA папки, например,
`/usr/sap/${SAPSYSTEMNAME}/SYS/global/hdb/custom/python_support`.
Далее используется переменная `HCH_EXE_DIR` для указания папки исполняемых файлов:

```bash
HCH_EXE_DIR=/opt/hanacleaner
```

Подготовить папку исполняемых файлов:

```bash
[[ -d $HCH_EXE_DIR ]] || \
    ( mkdir $HCH_EXE_DIR && chgrp sapsys $HCH_EXE_DIR && chmod 775 $HCH_EXE_DIR )
ls -ld $HCH_EXE_DIR
```

В папку исполняемых файлов необходимо скопировать:

- python-скрипт HANACleaner `hanacleaner.py` и
- скрипт-исполнитель `opt/hanacleaner-starter.sh`.

```bash
cp $HC_REPO_DIR/hanacleaner.py $HCH_EXE_DIR
cp $HCH_REPO_DIR/opt/hanacleaner/hanacleaner_starter.sh $HCH_EXE_DIR
chgrp sapsys $HCH_EXE_DIR/hanacleaner.py $HCH_EXE_DIR/hanacleaner_starter.sh 
chmod 755 $HCH_EXE_DIR/hanacleaner_starter.sh
```

Протестировать запуск скрипта `hanacleaner_starter.sh`:

```sh
$HCH_EXE_DIR/hanacleaner_starter.sh --help
```

Подготовить папку конфигурационных файлов
-------------------------------------------

По умолчанию скрипт-исполнитель для чтения конфигурационных файлов использует папку
`/etc/opt/hanacleaner`.

Можно использовать другую папку для хранения конфигурационных файлов.
Нестандартное расположение папки задается с помощью опции `--config-dir` при старте скрипта-исполнителя.

Далее используется переменная `HCH_CFG_DIR` для указания папки конфигурационных файлов:

```bash
HCH_CFG_DIR=/etc/opt/hanacleaner
```

Подготовить папку конфигурационных файлов:

```bash
[[ -d $HCH_CFG_DIR ]] || \
    ( mkdir $HCH_CFG_DIR && chgrp sapsys $HCH_CFG_DIR && chmod 775 $HCH_CFG_DIR )
ls -ld $HCH_CFG_DIR
```

Скопировать из папки `$HCH_REPO_DIR/etc/opt/hanacleaner/` шаблоны конфигурационных файлов для типовых задач.
На текущий момент доступны следующие шаблоны:

- `template_housekeeping.conf` - шаблон задачи автоматической периодической очистки БД HANA,
- `template_release_logs.conf` - шаблон задачи очистки свободных журнальных файлов БД HANA.

```sh
cp $HCH_REPO_DIR/etc/opt/hanacleaner/template_housekeeping.conf $HCH_CFG_DIR
cp $HCH_REPO_DIR/etc/opt/hanacleaner/template_release_logs.conf $HCH_CFG_DIR
chgrp sapsys $HCH_CFG_DIR/*
chmod 664 $HCH_CFG_DIR/*
```



Для доступа администраторов ОС БД HANA к конфигурационным файлам необходимо установить группу `sapsys` для папки и файлов. 
Для папки установить маску прав 775, для файлов - 664.


Подготовить папку журналов работы
---------------------------------

Для записи журналов работы скрипт-исполнитель использует папку /var/opt/hanaleaner.
Можно использовать другую папку для записи журналов.
Нестандартное расположение папки задается с помощью опции `--log-dir` при старте скрипта-исполнителя.

```sh
[[ -d /var/opt/hanacleaner ]] || mkdir /var/opt/hanacleaner
chgrp -R sapsys /var/opt/hanacleaner
```
