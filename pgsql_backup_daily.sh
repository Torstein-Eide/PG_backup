#!/bin/bash
# Shell script to backup PostgreSQL database
set -euo pipefail
IFS=$'\n\t'
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $DIR

#Used for Temp folder
scriptname="$0"
scriptname=${scriptname::-3}
export scriptname=${scriptname:2}

############################################
###Remember to edit ./pgsql_backup_common.sh###
############################################


# How many days old files must be to be removed
export DAYS=31


## Backup Dest directory
export DEST="/volum/@backup/pgsql/daily" # edit me

./pgsql_backup_common.sh

# Remove old files
find $DEST -mtime +$DAYS -exec rm -f {} \;

echo ""
echo "PostgreSQL backup is completed"
