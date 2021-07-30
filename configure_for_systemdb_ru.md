Конфигурирование HANACleaner для системной БД HANA
===

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

Определить административную учетную запись и пароль в системной БД:

```bash
SYSTEMDB_ADM_USER_NAME=SYSTEM
SYSTEMDB_ADM_USER_NAME=???
```

---

В системной БД HANA будет создана техническая учетная запись пользователя `HANACLEANER_USER_NAME`
от имени которой HANACleaner будет запускать SQL-команды.
Пароль будет установлен в `HANACLEANER_USER_PWD`.

Определить техническую учетную запись пользователя в системной БД:

```bash
HANACLEANER_USER_NAME=TCU4CLEANER
HANACLEANER_USER_PWD=?
```

---

Определить папки HANACleaner:

```bash
HC_SCRIPT_DIR=/opt/hanacleaner
HC_CONFIG_DIR=/etc/opt/hanacleaner
```

---

Подготовить и протестировать команду запуска `hdbsql`:

```bash
HDBSQL="${DIR_EXECUTABLE}/hdbsql -d SYSTEMDB -n localhost -i ${TINSTANCE} -u $SYSTEMDB_ADM_USER_NAME -p \"${SYSTEMDB_ADM_USER_PWD}\""
$HDBSQL "SELECT * FROM DUMMY"
```

Подготовить пользователя для HANACleaner
---

Создать техническую учетную запись пользователя для HANACleaner и
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
$HDBSQL "GRANT SELECT,DELETE ON _SYS_REPO.OBJECT_HISTORY TO $HANACLEANER_USER_NAME"
```

Создать ключ в HANA Secure User Store
---

Определить и визуально проверить порт сервиса HANA `nameserver`:

```bash
HANA_NAMESERVER_PORT=$($HDBSQL -C -a -x "SELECT SQL_PORT FROM SYS_DATABASES.M_SERVICES WHERE DATABASE_NAME='SYSTEMDB' AND SERVICE_NAME='nameserver' AND COORDINATOR_TYPE= 'MASTER'")
echo HANA_NAMESERVER_PORT is "$HANA_NAMESERVER_PORT"
```

---

Создать ключ для технической учетной записи пользователя HANACleaner пользователя HANA Secure User Store:

```bash
hdbuserstore LIST KEY4CLEANER
hdbuserstore SET KEY4CLEANER "localhost":$HANA_NAMESERVER_PORT $HANACLEANER_USER_NAME $HANACLEANER_USER_PWD
hdbuserstore LIST KEY4CLEANER
```

---

Проверить подключение к HANA с использованием записи в HANA Secure User Store:

```bash
${DIR_EXECUTABLE}/hdbsql -U KEY4CLEANER "SELECT * FROM DUMMY"
```

Подготовить параметры задачи housekeeping
---

Подготовить шаблон задачи housekeeping для контейнера HANA:

```bash
cp $HC_CONFIG_DIR/template_housekeeping.conf $HC_CONFIG_DIR/${SAPSYSTEMNAME}_housekeeping.conf
```

```bash
$HC_SCRIPT_DIR/hanacleaner_starter.sh --hc-opts "-dbs SYSTEMDB -es false" housekeeping
```
