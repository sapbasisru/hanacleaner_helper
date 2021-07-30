#!/bin/bash

showHelp() {
    cat<<EOF
Name
    hanacleaner_starter - Starter the HANACleaner script hanacleaner.py in the predifined environment.

Usage
  hanacleaner_starter.sh [OPTION...] TASK...

Description:

Examples:
    # start HANACleaner with TASK 'housekeeping'
    hanacleaner_startert.sh housekeeping

    # start HANACleaner with TASK 'release_logs' for SYSTEM database
    hanacleaner_startert.sh release_logs --hc_opts='-dbs SYSTEM'

Options:
    --task-dir <config directory>
        Use <config directory> as source for search configuration files instead a default directory. 
        The default configuration directory is /opt/hanacleaner.

    --hc-opts <"HANACleaner options">
        Pass additional options to the HANACleaner script.
        The options should be enclosured with quote or double quote.

    --hc-dir <HANACleaner script directory>
        Use <HANACleaner script directory> as source directory for HANACleaner script hanacleaner.py.
        If not set then the program will use current directory, /opt/hanacleaner, 
        /usr/sap/<SAPSYSTEMNAME>/SYS/global/hdb/custom/python_support
        for searching the HANACleaner script hanacleaner.py.
    
    --log-dir <logging directory>
        Use <logging directory> as destination for logging instead a default directory.
        The default logging directory is /var/opt/hanacleaner.

    --help
        Display this help and exit.

EOF
}

exitWithError() {
    echo "error: ${1}. Terminated with code ${2}..." >&2 ; exit $2
}

# Parse command line options
# ---
getopt --test &>/dev/null
if [[ $? -ne 4 ]]; then 
    exitWithError "Getopt is too old" -2
fi

declare HC_SCRIPT_NAME="hanacleaner.py"
declare HC_CONFIG_DIR="/etc/opt/hanacleaner"
declare HC_LOG_DIR="/var/opt/hanacleaner"
declare {HC_SCRIPT_DIR,HC_OPTS,HC_TASKS_ID}=''

OPTS=$(getopt -s bash -o '' --longoptions 'help,config-dir:,log-dir:,hc-dir:,hc-opts:' -n "$0" -- "$@")
if [[ $? -ne 0 ]] ; then 
    exitWithError "Failed parsing options" -2
fi
eval set -- "$OPTS"

while true; do
  case "$1" in
    --config-dir)
        HC_CONFIG_DIR=$2
        shift 2
        ;;
    --log-dir)
        HC_LOG_DIR=$2
        shift 2
        ;;
    --hc-dir)
        HC_SCRIPT_DIR=$2
        shift 2
        ;;
    --hc-opts)
        HC_OPTS="$2"
        shift 2
        ;;
    --)
        shift
        break
        ;;
    *)
        showHelp
        exit 0
        ;;
  esac
done

if [[ -z "$@" ]]; then
    HC_TASK_IDS=("housekeeping")
else
    HC_TASK_IDS=("$@")
fi
echo HC_TASK_IDS = ${HC_TASK_IDS[@]}

# Eval & check location of HANACleaner script
# ---
if [[ ! -z "$HC_SCRIPT_DIR" ]]; then
    if [[ ! -f ${HC_SCRIPT_DIR}/$HC_SCRIPT_NAME ]]; then
        exitWithError "The HANACleaner script ('$HC_SCRIPT_NAME') is not found in the specified directory '$HC_SCRIPT_DIR'" -3
    fi
else
    HC_SCRIPT_CANDIDAT_DIRS=($(dirname $0) /usr/sap/${SAPSYSTEMNAME}/SYS/global/hdb/custom/python_support /opt/hanacleaner)
    for HC_SCRIPT_CANDIDAT_DIR in ${HC_SCRIPT_CANDIDAT_DIRS[@]}; do
        if [[ -f "$HC_SCRIPT_CANDIDAT_DIR/$HC_SCRIPT_NAME" ]]; then
            HC_SCRIPT_DIR=$HC_SCRIPT_CANDIDAT_DIR
            break
        fi
    done
fi
if [[ -z "$HC_SCRIPT_DIR" ]]; then
    exitWithError "The HANACleaner script ('$HC_SCRIPT_NAME') is not found" -3
fi
echo "info: I will use the HANACleaner script ('$HC_SCRIPT_NAME') form directory '$HC_SCRIPT_DIR'..."

# Eval & check configurations direcory
# ---
[ -z "$HC_CONFIG_DIR" ] && HC_CONFIG_DIR='/etc/opt/hanacleaner'
if [[ ! -d "$HC_CONFIG_DIR" ]]; then
    exitWithError "The configuration directory '${HC_CONFIG_DIR}' is not exists" -4
fi

# Construct HANACleaner command and suffix
# ---
HC_EXEC_CMD="python $(eval echo $HC_SCRIPT_DIR/$HC_SCRIPT_NAME)"
HC_EXEC_END="$(eval echo -op $HC_LOG_DIR -of ${SAPSYSTEMNAME}_$(basename $SAP_RETRIEVAL_PATH))"
[[ -z "$HC_OPTS" ]] || HC_EXEC_END="$HC_EXEC_END $HC_OPTS"

# Start HANACleaner script
# ---
for HC_TASK_ID in ${HC_TASK_IDS[@]}; do
    HC_TASK_CONFIG_FILE=$HC_CONFIG_DIR/${SAPSYSTEMNAME}_${HC_TASK_ID}.conf
    [[ -f "$HC_TASK_CONFIG_FILE" ]] || HC_TASK_CONFIG_FILE=$HC_CONFIG_DIR/${HC_TASK_ID}.conf
    if [[ ! -f "$HC_TASK_CONFIG_FILE" ]]; then
        echo "warning: The configuration file for task '${HC_TASK_ID}' not found. Skipping this task..."
        continue
    fi
    echo "info: Try to start HANACleaner for task '${HC_TASK_ID}':"
    echo "info:   $HC_EXEC_CMD -ff $HC_TASK_CONFIG_FILE $HC_EXEC_END"
    $HC_EXEC_CMD -ff $HC_TASK_CONFIG_FILE $HC_EXEC_END
done
