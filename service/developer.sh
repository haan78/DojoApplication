#!/bin/sh
echo "DEVELOPER RUNING..."
cd /var/www/html
if [ ! -f "./composer.lock" ]
then
    echo "COMPOSER INSTALL"	
    composer install
    if [ ! -f "./composer.lock" ]
    then
        echo "Lock file could not create"
        exit 1
    fi	
else
    echo "Lock file is already exist"
fi

apache2-foreground