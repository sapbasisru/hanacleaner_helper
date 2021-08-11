Обновление скрипта HANACleaner
==============================

Команды, приведенные ниже, могут использоваться для обновления скриптов `hanacleaner.py` и `hanacleaner-starter.sh`.
Предполагается, что первоначальная инсталляция скриптов уже выполнена с помощью командного файла
[install_ru.md](install_ru.md).

>[!NOTE]
>:point_up: Команды выполняются на сервере HANA от имени учетной записи `root`.

Обновить Git-репозитории
------------------------

Обновить два репозитория с GitHub:

- `https://github.com/sapbasisru/hanacleaner.git` - репозиторий, содержащий python-скрипт HANACleaner (`hanacleaner.py`).
- `https://github.com/sapbasisru/hanacleaner_helper.git` - репозиторий, содержащий скрипт-исполнитель и подготовленные конфигурационные файлы.

В дальнейшем предполагается,
что переменные `HC_REPO_DIR` и `HCH_REPO_DIR` указывают на папки с локальными копиями репозиториев.
Предположим, что используются пути
`/stage/sapbasisru.github/hanacleaner.git` и
`/stage/sapbasisru.github/hanacleaner_helper.git` соответственно:

```bash
HC_REPO_DIR=/stage/sapbasisru.github/hanacleaner.git
HCH_REPO_DIR=/stage/sapbasisru.github/hanacleaner_helper.git
```

Обновить репозиторий [hanacleaner.git](https://github.com/sapbasisru/hanacleaner.git):

```bash
cd $HC_REPO_DIR && git pull origin master
```

Обновить репозиторий [hanacleaner_helper.git](https://github.com/sapbasisru/hanacleaner_helper.git):

```bash
cd $HCH_REPO_DIR && git pull origin main
```

Подготовить папку для исполняемых файлов
----------------------------------------

Переменная `HC_SCRIPT_DIR` используется для указания папки исполняемых файлов.
Предположим, что используется путь `/opt/hanacleaner`:

```bash
HC_SCRIPT_DIR=/opt/hanacleaner
```

В папку исполняемых файлов необходимо скопировать:

- python-скрипт HANACleaner `hanacleaner.py` и
- скрипт-исполнитель `opt/hanacleaner-starter.sh`.

```bash
cp $HC_REPO_DIR/hanacleaner.py $HC_SCRIPT_DIR
cp $HCH_REPO_DIR/opt/hanacleaner/hanacleaner_starter.sh $HC_SCRIPT_DIR
```

Протестировать запуск скрипта `hanacleaner_starter.sh`:

```sh
$HC_SCRIPT_DIR/hanacleaner_starter.sh --help
```
