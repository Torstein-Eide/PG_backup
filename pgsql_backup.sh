#
# Backup a Postgresql database into a daily file.
#

BACKUP_DIR=/pg_backup
DAYS_TO_KEEP=14
FILE=`date +"%Y%m%d"`_pg_backup.sql
DATABASE=
USER=postgres

OUTPUT_FILE=${BACKUP_DIR}/${FILE}

# (2) in case you run this twice in one day, remove the previous version of the file
unalias rm     2> /dev/null
rm ${OUTPUT_FILE}     2> /dev/null
rm ${OUTPUT_FILE}.gz  2> /dev/null

# (3) do the database backup (dump)
# use this command for a database server on localhost. add other options if need be.
pg_dump -U ${USER} ${DATABASE} -F p -f ${OUTPUT_FILE}

# (4) gzip the mysql database dump file
gzip $OUTPUT_FILE

# (5) show the user the result
echo "${OUTPUT_FILE}.gz was created:"
ls -l ${OUTPUT_FILE}.gz

# (6) prune old backups
find $BACKUP_DIR -maxdepth 1 -mtime +$DAYS_TO_KEEP -name "*-pg_backup.sql.gz" -exec rm -rf '{}' ';'