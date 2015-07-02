#!/bin/bash
DIR=$1
source $DIR/provisioners/shell/env.sh

echo "*** NGINX ***"

# MYSQL
$DIR/provisioners/shell/serverhttp/installer-mysql.sh $DIR

# PHP
$DIR/provisioners/shell/serverhttp/installer-php.sh $DIR

# PHPMYADMIN
$DIR/provisioners/shell/serverhttp/installer-phpmyadmin.sh $DIR

# NGINX
$DIR/provisioners/shell/serverhttp/installer-nginx.sh $DIR

echo "Restart mysql for the config to take effect"
sudo service mysql restart

echo "Restart php5 fpm for the config to take effect"
sudo service php5-fpm restart

echo "Restart Nginx for the config to take effect"
sudo service nginx restart
