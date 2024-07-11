
#!/bin/bash

###### THIS the common config file, do not run this directly

#control for dependeces
# Linux bin paths
PSQL="$(which psql)"
PSQLDUMP="$(which pg_dump)"
ZSTD="$(which zstd)"

if [ -z $ZSTD ] || [ -z $PSQL ] || [ -z $PSQLDUMP ]
then
 echo "missing dependeces"
  apt install zstd postgresql-client-10
fi

# Email for notifications
EMAIL=

#Text Colors
GREEN=`tput setaf 2`
RED=`tput setaf 1`
NC=`tput sgr0` #No color

#Output Strings
GOOD="${GREEN}NO${NC}"
BAD="${RED}YES${NC}"

# Get date in dd-mm-yyyy format
NOW="$(date +"%Y-%m-%d_%H%M")"

# Create Backup sub-directories
MBD="$TEMPdir/$NOW/mysql"

# DB skip list
SKIP="template0
template1"

# Get all databases
DBS="$(psql -lqt | cut -d \| -f 1 | sed -e 's/^\s*//' -e '/^$/d')" || exit
echo -e "${NC}list of databases:"
for i in $DBS
do
	echo "* $GREEN$i${NC}"
done
#\n$GREEN$DBS${NC}


#make temp dir
install -d $MBD
chmod 700 $MBD


#make dir
if [ ! -d $DEST ]
then
	echo "Directory does not $DEST exist, making dir"
	mkdir -v $DEST || echo "problem exiting" | exit
	chmod 700 $DEST
else
	echo "Directory $DEST exist"
	fi


dbdump() {
skipdb=-1
START="$(date "+%s%N")"
if [ "$SKIP" != "" ];
  then
    for i in $SKIP
     do
      [ "$db" == "$i" ] && skipdb=1 || :
     done
    fi

    if [ "$skipdb" == "-1" ]
     then
        FILE="$MBD/$db.sql"

        if $PSQLDUMP  $db > /dev/null ; then
          $PSQLDUMP  $db -f $FILE
          TT=$(printf %.4f "$(("$(date "+%s%N")" - $START))e-9")
          echo "Extracted $GREEN$db${NC} $TT s"
        else
          echo "Extracted $db${NC} ${RED}FAILED${NC}"
        fi

     else
        echo "Skiping   $RED$db${NC}"
    fi
}

# Archive database dumps
for db in $DBS
do
dbdump &
done
#FAIL=0
#jobs verbose
#for job in `jobs -p`
#do
#    wait $job || let "FAIL+=1"
#done
wait
# Archive the directory, send mail and cleanup
cd  $TEMPdir
du -hs $TEMPdir
tar -I "zstd --adapt=max=15 --adapt=min=3 -T0" -cf $DEST/$NOW.tar.zst $NOW
du -hs $DEST/$NOW.tar.zst
#$GZIP -9 $NOW.tar
cd /tmp
#remove temp file
rm -rf $TEMPdir

if [ -n "$EMAIL" ]
then
        echo "
        To: $EMAIL
        Subject: PGSQL backup
        PGSQL backup is completed! Backup name is $NOW.tar.zst" | ssmtp $EMAIL

else
echo "${RED}mail not setup${NC}"
fi
