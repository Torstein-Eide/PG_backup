#!/bin/bash
# Shell script to backup PostgreSQL database
set -euo pipefail
IFS=$'\n\t'
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $DIR

##################################
#  Remember to edit ./config.sh  #
##################################
source config.sh

#Used for Temp folder
scriptname="$0"
scriptname=${scriptname::-3}
export scriptname=pgsql_backup_daily

############################################
###Remember to edit ./pgsql_backup_common.sh###
############################################


## Backup Dest directory
export DEST="$DESTDIR/daily" # edit me

./pgsql_backup_common.sh

# Remove old files
find $DEST -mtime +$DAYS -exec rm -f {} \;

echo ""
echo "PostgreSQL backup is completed"
