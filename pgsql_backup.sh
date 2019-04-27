#!/bin/bash
#
# Backup a Postgresql database into a daily file.
#

BACKUP_DIR=/volum/@backup/pg_backup
DAYS_TO_KEEP=14
FILE_SUFFIX=pg_backup.sql
DATABASE=
USER=postgres

# Get date in dd-mm-yyyy format
	NOW="$(date +"%Y-%m-%d_%H%M")"

FILE=$NOW/${FILE_SUFFIX}
TMP_folder=/tmp/Postgresql
# do the database backup (dump)
# use this command for a database server on localhost. add other options if need be.
#pg_dump -U ${USER} ${DATABASE} -F p -f ${OUTPUT_FILE}
install -d $TMP_folder/$NOW
chown -R ${USER}:${USER} $TMP_folder
chmod -R 700 $TMP_folder
su - ${USER} -c "pg_dumpall -f ${TMP_folder}/${FILE}" || exit
# gzip the mysql database dump file
ls -hs ${TMP_folder}/${FILE}
cd ${TMP_folder}
tar -I "xz -T0" -cf ${BACKUP_DIR}/$NOW.tar.xz $NOW
rm -r $TMP_folder

# show the user the result
echo "${BACKUP_DIR}/${NOW}.tar.xz was created:"
ls -hs ${BACKUP_DIR}/${NOW}.tar.xz

# prune old backups
find $BACKUP_DIR -maxdepth 1 -mtime +$DAYS_TO_KEEP -name "*${FILE_SUFFIX}.gz" -exec rm -rf '{}' ';'
find $BACKUP_DIR -maxdepth 1 -mtime +$DAYS_TO_KEEP -name "*${FILE_SUFFIX}.xz" -exec rm -rf '{}' ';'
find $BACKUP_DIR -maxdepth 1 -mtime +$DAYS_TO_KEEP -name "*${FILE_SUFFIX}.tar.xz" -exec rm -rf '{}' ';'
