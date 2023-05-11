#!/bin/sh
sqlfile="/tmp/dojo"$(date +%Y%m%d%H%M%S)".sql"
zipfile=$sqlfile".gz"
if [ -z "$zipfile" ]; then
    gzip -c $sqlfile > $zipfile
    if [ -z "$zipfile" ]; then
        if [ -d $1 ]; then
            mv $zipfile $1
            exit 0
        else
            echo "error: klasor bulunamadi"
        fi        
    else
        echo "error: ZIP dosyasi olusturulamadi!"
    fi
else
    echo "error: SQL yedek olusturulamadi!"
fi
exit 1
