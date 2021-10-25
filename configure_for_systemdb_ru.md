Конфигурирование HANACleaner для системной БД HANA
===

>[!NOTE]
>:point_up: Команды выполняются на сервере HANA от имени учетной записи `<hana_sid>adm`.

Подготовить окружение для выполнения команд
---

Проверить работу скрипта `hanacleaner.py`:

```bash
python /opt/hanacleaner/hanacleaner.py --help
```

---

Запуск команд в системной БД HANA выполняется
от имени административной учетной записи пользователя `SYSTEMDB_ADM_USER_NAME`,
с паролем `SYSTEMDB_ADM_USER_PWD`.
Установить имя административной учетной записи в системной БД:

```bash
SYSTEMDB_ADM_USER_NAME=SYSTEM
```

Установить пароль административной учетной записи:

```bash
SYSTEMDB_ADM_USER_PWD=<Пароль пользователя SYSTEM>
```

---

В системной БД HANA будет создана техническая учетная запись пользователя `HANACLEANER_USER_NAME`
от имени которой HANACleaner будет запускать SQL-команды.
Пароль будет установлен в `HANACLEANER_USER_PWD`.
Установить имя технического пользователя:

```bash
HANACLEANER_USER_NAME=TCU4CLEANER
```

Установить пароль технического пользователя:

```bash
HANACLEANER_USER_PWD=<Пароль пользователя TCU4CLEANER>
```

---

Определить папки *HANACleaner*:

```bash
HC_SCRIPT_DIR=/opt/hanacleaner
HC_CONFIG_DIR=/etc/opt/hanacleaner
HC_LOG_DIR=/var/opt/hanacleaner
```

---

Подготовить и протестировать команду запуска `hdbsql`:

```bash
HDBSQL="${DIR_EXECUTABLE}/hdbsql -d SYSTEMDB -n localhost -i ${TINSTANCE} -u $SYSTEMDB_ADM_USER_NAME -p \"${SYSTEMDB_ADM_USER_PWD}\" -j"
$HDBSQL "SELECT * FROM DUMMY"
```

Подготовить пользователя для HANACleaner
---

Создать техническую учетную запись пользователя для *HANACleaner* и
предоставить необходимые права:

```bash
$HDBSQL "CREATE USER $HANACLEANER_USER_NAME PASSWORD \"$HANACLEANER_USER_PWD\" NO FORCE_FIRST_PASSWORD_CHANGE"
$HDBSQL "ALTER USER $HANACLEANER_USER_NAME DISABLE PASSWORD LIFETIME"
$HDBSQL "GRANT AUDIT ADMIN TO $HANACLEANER_USER_NAME"
$HDBSQL "GRANT AUDIT OPERATOR TO $HANACLEANER_USER_NAME"
$HDBSQL "GRANT BACKUP ADMIN TO $HANACLEANER_USER_NAME"
$HDBSQL "GRANT BACKUP OPERATOR TO $HANACLEANER_USER_NAME"
$HDBSQL "GRANT CATALOG READ TO $HANACLEANER_USER_NAME"
$HDBSQL "GRANT LOG ADMIN TO $HANACLEANER_USER_NAME"
$HDBSQL "GRANT MONITOR ADMIN TO $HANACLEANER_USER_NAME"
$HDBSQL "GRANT RESOURCE ADMIN TO $HANACLEANER_USER_NAME"
$HDBSQL "GRANT TRACE ADMIN TO $HANACLEANER_USER_NAME"
$HDBSQL "GRANT SELECT,DELETE ON _SYS_STATISTICS.HOST_OBJECT_LOCK_STATISTICS_BASE TO $HANACLEANER_USER_NAME"
$HDBSQL "GRANT SELECT,DELETE ON _SYS_STATISTICS.STATISTICS_ALERTS_BASE TO $HANACLEANER_USER_NAME"
$HDBSQL "GRANT SELECT,DELETE ON _SYS_STATISTICS.STATISTICS_EMAIL_PROCESSING TO $HANACLEANER_USER_NAME"
$HDBSQL "GRANT SELECT,DELETE ON _SYS_REPO.OBJECT_HISTORY TO $HANACLEANER_USER_NAME"
```

Создать ключ в HANA Secure User Store
---

Определить и визуально проверить порт сервиса HANA `nameserver`:

```bash
HANA_NAMESERVER_PORT=$($HDBSQL -C -a -x "SELECT SQL_PORT FROM SYS_DATABASES.M_SERVICES WHERE DATABASE_NAME='SYSTEMDB' AND SERVICE_NAME='nameserver' AND COORDINATOR_TYPE= 'MASTER'")
echo "`tput setaf 2`HANA nameserver port is`tput sgr0` : [`tput setaf 1`$HANA_NAMESERVER_PORT`tput sgr0`]"
```

---

Создать ключ для технической учетной записи пользователя *HANACleaner* в HANA Secure User Store:

```bash
hdbuserstore LIST KEY4CLEANER
hdbuserstore SET KEY4CLEANER $(basename $SAP_RETRIEVAL_PATH):$HANA_NAMESERVER_PORT $HANACLEANER_USER_NAME $HANACLEANER_USER_PWD
hdbuserstore LIST KEY4CLEANER
```

---

Проверить подключение к HANA с использованием записи в HANA Secure User Store:

```bash
${DIR_EXECUTABLE}/hdbsql -U KEY4CLEANER -j "SELECT * FROM DUMMY"
```

Подготовить параметры задачи housekeeping
---

Подготовить задачу *housekeeping* для контейнера HANA на основе имеющегося шаблона:

```bash
cp $HC_CONFIG_DIR/template_housekeeping.conf $HC_CONFIG_DIR/${SAPSYSTEMNAME}_housekeeping.conf
```

Скорректировать, параметры задачи *housekeeping*.
В конфигурационном файле необходимо, как минимум, внести значение `SYSTEMDB` для параметра `-dbs` как показно ниже:

```
-dbs SYSTEMDB
```

Открыть на редактирование файл задачи *housekeeping* и внести необходимые изменения:

```bash
vim $HC_CONFIG_DIR/${SAPSYSTEMNAME}_housekeeping.conf
```

---

Запустить *HANACleaner* в режиме демонстрации:

```bash
$HC_SCRIPT_DIR/hanacleaner_starter.sh --hc-opts "-es false" housekeeping
```

Запустить *HANACleaner* в режиме исполнения:

```bash
$HC_SCRIPT_DIR/hanacleaner_starter.sh housekeeping
```

Запланировать запуск скрипта через crontab
---

Добавить в планировщик ОС *crontab* ежедневный запуск *HANACleaner* в час ночи:

```bash
( crontab -l ; \
cat<<EOF
# Start HANACleaner for housekeeping tasks for HANA MDC $SAPSYSTEMNAME 
0 1 * * * $HC_SCRIPT_DIR/hanacleaner_starter.sh housekeeping > $HC_LOG_DIR/hanacleanercron_${SAPSYSTEMNAME}.txt 2>&1
EOF
) | crontab -
```
