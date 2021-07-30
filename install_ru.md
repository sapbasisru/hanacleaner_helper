Инсталляция скрипта HANACleaner
===============================

>[!NOTE]
>:point_up: Команды выполняются на сервере HANA от имени учетной записи `root`.

Загрузить Git-репозитарии
--------------------------

Для работы с HANACleaner потребуется загрузить два репозитария с GitHub:

- `https://github.com/sapbasisru/hanacleaner.git` - репозитарий, содержащий python-скрипт HANACleaner (`hanacleaner.py`).
- `https://github.com/sapbasisru/hanacleaner_helper.git` - репозитарий, содержащий скрипт-исполнитель и подготовленные конфигурационные файлы.

Загрузить репозитарий можно либо с помощью команды `git clone` или другими средствами.

В дальнейшем предполагается, что переменные `HC_REPO_DIR` и `HCH_REPO_DIR` указывают на папки с локальными копиями репозитариев.

Скопировать/обновить репозитарий `hanacleaner.git`:

```bash
[[ -d $HC_REPO_DIR ]] || \
    git clone https://github.com/sapbasisru/hanacleaner.git $HC_REPO_DIR
cd $HC_REPO_DIR && git pull origin master
```

Скопировать/обновить репозитарий `hanacleaner_helper.git`:

```bash
[[ -d $HCH_REPO_DIR ]] || \
    git clone https://github.com/sapbasisru/hanacleaner_helper.git $HCH_REPO_DIR
cd $HCH_REPO_DIR && git pull origin main
```

Подготовить папку для исполняемых файлов
----------------------------------------

В простых случаях для размещения исполняемых файлов можно использовать
локальную папку `/opt/hanacleaner`.
Возможно, для scale-out конфигураций HANA, более простым в экслуатации решением
будет использование общей для всех узлов HANA папки, например,
`/usr/sap/${SAPSYSTEMNAME}/SYS/global/hdb/custom/python_support`.
Далее используется переменная `HC_SCRIPT_DIR` для указания папки исполняемых файлов:

```bash
HC_SCRIPT_DIR=/opt/hanacleaner
```

Подготовить папку исполняемых файлов:

```bash
[[ -d $HC_SCRIPT_DIR ]] || \
    ( mkdir $HC_SCRIPT_DIR && chgrp sapsys $HC_SCRIPT_DIR && chmod 775 $HC_SCRIPT_DIR )
ls -ld $HC_SCRIPT_DIR
```

В папку исполняемых файлов необходимо скопировать:

- python-скрипт HANACleaner `hanacleaner.py` и
- скрипт-исполнитель `opt/hanacleaner-starter.sh`.

```bash
cp $HC_REPO_DIR/hanacleaner.py $HC_SCRIPT_DIR
cp $HCH_REPO_DIR/opt/hanacleaner/hanacleaner_starter.sh $HC_SCRIPT_DIR
chgrp sapsys $HC_SCRIPT_DIR/hanacleaner.py $HC_SCRIPT_DIR/hanacleaner_starter.sh 
chmod 755 $HC_SCRIPT_DIR/hanacleaner_starter.sh
```

Протестировать запуск скрипта `hanacleaner_starter.sh`:

```sh
$HC_SCRIPT_DIR/hanacleaner_starter.sh --help
```

Подготовить папку конфигурационных файлов
-------------------------------------------

По умолчанию скрипт-исполнитель для чтения конфигурационных файлов использует папку
`/etc/opt/hanacleaner`.

Можно использовать другую папку для хранения конфигурационных файлов.
Нестандартное расположение папки задается с помощью опции `--config-dir` при старте скрипта-исполнителя.

Далее используется переменная `HC_CONFIG_DIR` для указания папки конфигурационных файлов:

```bash
HC_CONFIG_DIR=/etc/opt/hanacleaner
```

Подготовить папку конфигурационных файлов:

```bash
[[ -d $HC_CONFIG_DIR ]] || \
    ( mkdir $HC_CONFIG_DIR && chgrp sapsys $HC_CONFIG_DIR && chmod 775 $HC_CONFIG_DIR )
ls -ld $HC_CONFIG_DIR
```

Скопировать из папки `$HCH_REPO_DIR/etc/opt/hanacleaner/` шаблоны конфигурационных файлов для типовых задач.
На текущий момент доступны следующие шаблоны:

- `template_housekeeping.conf` - шаблон задачи автоматической периодической очистки БД HANA,
- `template_release_logs.conf` - шаблон задачи очистки свободных журнальных файлов БД HANA.

```sh
cp $HCH_REPO_DIR/etc/opt/hanacleaner/template_housekeeping.conf $HC_CONFIG_DIR
cp $HCH_REPO_DIR/etc/opt/hanacleaner/template_release_logs.conf $HC_CONFIG_DIR
chgrp sapsys $HC_CONFIG_DIR/*
chmod 664 $HC_CONFIG_DIR/*
```

Подготовить папку журналов работы
---------------------------------

Для записи журналов работы скрипт-исполнитель использует папку /var/opt/hanaleaner.
Можно использовать другую папку для записи журналов.
Нестандартное расположение папки задается с помощью опции `--log-dir` при старте скрипта-исполнителя.

```bash
HC_LOG_DIR=/var/opt/hanacleaner
```

Подготовить папку журналов работы:

```bash
[[ -d $HC_LOG_DIR ]] || \
    ( mkdir $HC_LOG_DIR && chgrp sapsys $HC_LOG_DIR && chmod 775 $HC_LOG_DIR )
ls -ld $HC_LOG_DIR
```
