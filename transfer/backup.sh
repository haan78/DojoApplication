#!/bin/sh
logdir=/var/backups/dojo
sqlfile=$logdir/dojo.sql
zipfile="$logdir/dojo"$(date +%Y%m%d%H%M%S)".sql.gz"

find $logdir -mtime +90 -type f -delete

if [ -f "$sqlfile" ]; then
    rm -f $sqlfile
fi

mysqldump -uroot -p$1 --default-character-set=utf8mb4 --routines --triggers --databases --comments=1 dojo -r $sqlfile

if [ -f "$sqlfile" ]; then
    gzip -c $sqlfile > $zipfile
    if [ -f "$zipfile" ]; then
        rm -f $sqlfile
        echo "success: $zipfile";
        exit 0;
    else
        echo "error: ZIP dosyasi olusturulamadi!"
    fi
else
    echo "error: SQL yedek olusturulamadi!"
fi
exit 1
