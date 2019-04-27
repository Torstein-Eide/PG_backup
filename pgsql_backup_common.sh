# THIS the common config file, do not run this directly

#control for dependeces
# Linux bin paths
PSQL="$(which psql)"
PSQLDUMP="$(which ps_dump)"
PXZ="$(which pxz)"

if [ -z $PXZ ] || [ -z $ ] 
then
 echo "missing dependeces"
  apt install pigz m
fi


#Text Colors
GREEN=`tput setaf 2`
RED=`tput setaf 1`
NC=`tput sgr0` #No color

#Output Strings
GOOD="${GREEN}NO${NC}"
BAD="${RED}YES${NC}"

# Set these variables
MyUSER="backup"	# DB_USERNAME # edit me
MyPASS="2001:4661:4f72:0"	# DB_PASSWORDc
MyHOST="localhost"	# DB_HOSTNAME # edit me

# Backup Dest directory
TEMPdir="/tmp/$scriptname"

# Email for notifications
EMAIL=


# Get date in dd-mm-yyyy format
NOW="$(date +"%Y-%m-%d_%H%M")"

# Create Backup sub-directories
MBD="$TEMPdir/$NOW/mysql"

# DB skip list
SKIP="information_schema
performance_schema
another_one_db"

# Get all databases
# su - postgres -c "psql -lqtA" | cut -d \| -f 1 | grep -v "^\W*$\|^postgres\="
DBS="$($MYSQL -h $MyHOST -u $MyUSER -p$MyPASS -Bse 'show databases')"
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
if [ "$db" == "mysql" ];
  then
   SKIPLOG="--skip-lock-tables"
  else
   SKIPLOG=""
 fi

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
		
        $MYSQLDUMP -h $MyHOST -u $MyUSER -p$MyPASS $db > $FILE 
		TT=$(printf %.4f "$(("$(date "+%s%N")" - $START))e-9")
		echo "extracted $GREEN$db${NC} $TT s"
		
     else
        echo "skiping   $RED$db${NC}"
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
cd $TEMPdir
du -hs $TEMPdir
tar -I "pxz -1" -cf $DEST/$NOW.tar.xz $NOW
du -hs $DEST/$NOW.tar.xz
#$GZIP -9 $NOW.tar
cd /tmp
#remove temp file
rm -rf $TEMPdir

if [ -n "$EMAIL" ]
then
echo "sant"
        echo "
        To: $EMAIL
        Subject: MySQL backup
        MySQL backup is completed! Backup name is $NOW.tar.gz" | ssmtp $EMAIL

else
echo "${RED}mail not setup${NC}"
fi
