Конфигурирование HANACleaner для прикладного тенанта HANA
===

Конфигурирование HANACleaner для прикладного тенанта выполняется после успешного конфигурирования для системной БД.

>[!NOTE]
>:point_up: Команды выполняются на сервере HANA от имени учетной записи `<hana_sid>adm`.

Подготовить окружение для выполнения команд
---

```bash
TENANTDB=$SAPSYSTEMNAME
```

Запуск команд в прикладном тенанте HANA выполняется
от имени административной учетной записи пользователя `TENANTDB_ADM_USER_NAME`,
с паролем `TENANTDB_ADM_USER_PWD`.
Установить имя административной учетной записи в системной БД:

```bash
TENANTDB_ADM_USER_NAME=SYSTEM
```

Установить пароль административной учетной записи:

```bash
TENANTDB_ADM_USER_PWD=<Пароль пользователя SYSTEM>
```

---

В прикладном тенанте будет создана техническая учетная запись пользователя `HANACLEANER_USER_NAME`
от имени которой HANACleaner будет запускать SQL-команды.
Пароль будет установлен в `HANACLEANER_USER_PWD`.

Имя и пароль пользователя ***должны совпадать*** с именем и паролем технического пользователя в системной БД.
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
HDBSQL="${DIR_EXECUTABLE}/hdbsql -d $TENANTDB -n localhost -i ${TINSTANCE} -u $TENANTDB_ADM_USER_NAME -p \"${TENANTDB_ADM_USER_PWD}\" -j"
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

---

Проверить подключение к HANA с использованием записи в HANA Secure User Store:

```bash
${DIR_EXECUTABLE}/hdbsql -U KEY4CLEANER -d $TENANTDB "SELECT * FROM DUMMY"
```

Подготовить параметры задачи housekeeping
---

Добавить в конфигурационный файл в параметр `-dbs` прикладной тенант.
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
