#!/bin/sh
wd=/var/www/html
bdir=$wd/backend/
lock=$bdir/composer.lock
echo "DEVELOPER RUNING..."
if [ ! -f "$lock" ]
then
    echo "COMPOSER INSTALL"
	cd $bdir
    composer install
    if [ ! -f "$lock" ]
    then
        echo "Lock file could not create"
        exit 1
    fi
	cd ..
else
    echo "Lock file is already exist"
fi

apache2-foreground