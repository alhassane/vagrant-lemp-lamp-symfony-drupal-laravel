#!/bin/sh

DIR=$(pwd)
chmod -R +x $DIR

INSTALL_USERWWW="/var/www/framework/fm-symfony"
PLATEFORM_INSTALL_TYPE="composer"
PLATEFORM_INSTALL_VERSION="2.4.0"
PLATEFORM_PROJET_NAME="sfproject24"
PLATEFORM_PROJET_NAME_LOWER=$(echo $PLATEFORM_PROJET_NAME |awk '{print tolower($0)}') # we lower the string
PLATEFORM_PROJET_NAME_UPPER=$(echo $PLATEFORM_PROJET_NAME |awk '{print toupper($0)}') # we lower the string
DATABASE_NAME="symfony_${PLATEFORM_PROJET_NAME_LOWER}"
DATABASE_NAME_TEST="symfony_${PLATEFORM_PROJET_NAME_LOWER}_test"
DOMAINE="Dirisi"
MYAPP_BUNDLE_NAME="Website"
MYAPP_PREFIX="dirisi"
FOSUSER_PREFIX="$MYAPP_PREFIX/admin"

echo "Removing Windows newlines on Linux (sed vs. awk)"
#find $DIR/provisioners/* -type f -exec dos2unix {} \;

echo "**** we create directories ****"
if [ ! -d $INSTALL_USERWWW ]; then
    mkdir -p $INSTALL_USERWWW
fi
cd $INSTALL_USERWWW

echo "**** we download artifact project ****"
if [ ! -d $PLATEFORM_PROJET_NAME ]; then
    case $PLATEFORM_INSTALL_TYPE in
        'composer' ) 
            #curl -s https://getcomposer.org/installer |php
            wget https://getcomposer.org/composer.phar -O ./composer.phar
            composer create-project --no-interaction symfony/framework-standard-edition $INSTALL_USERWWW/$PLATEFORM_PROJET_NAME $PLATEFORM_INSTALL_VERSION
            cd $PLATEFORM_PROJET_NAME
        ;;
        'stack' )
            curl -LsS http://symfony.com/installer -o /usr/local/bin/symfony
            chmod a+x /usr/local/bin/symfony
            symfony new $PLATEFORM_PROJET_NAME $PLATEFORM_VERSION
            cd $PLATEFORM_PROJET_NAME
        ;;
        'tar' )
            mkdir -p $PLATEFORM_PROJET_NAME
            cd $PLATEFORM_PROJET_NAME
            wget http://symfony.com/download?v=Symfony_Standard_Vendors_$PLATEFORM_VERSION.tgz
            tar -zxvf download?v=Symfony_Standard_Vendors_$PLATEFORM_VERSION.tgz
            mv Symfony/* ./
            #rm -rf download?v=Symfony_Standard_Vendors_$PLATEFORM_VERSION.tgz
            rm -rf Symfony
        ;;
    esac
else
    cd $PLATEFORM_PROJET_NAME
fi

#echo $(pwd)

echo "**** we install/update the composer file ****"
#wget https://getcomposer.org/composer.phar -O ./composer.phar
curl -sS https://getcomposer.org/installer |sudo php -- --install-dir=/usr/local/bin --filename=composer

echo "**** we create default directories ****"
if [ ! -d app/cache ]; then
    mkdir -p app/cache
    mkdir -p app/logs
    mkdir -p web/uploads/media
fi

echo "**** we modify parameters.yml.dist ****"
sed -i '/database_/d' app/config/parameters.yml.dist # delete lines witch contain "database"_ string
sed -i "/parameters:/r $DIR/artifacts/parameters.yml" app/config/parameters.yml.dist # we add lines contained in parameters.yml
sed -i "s/myproject/${PLATEFORM_PROJET_NAME_LOWER}/g" app/config/parameters.yml.dist

echo "**** we create parameters.yml ****"
if [ -f app/config/parameters.yml ]; then
    rm app/config/parameters.yml
fi
cp app/config/parameters.yml.dist app/config/parameters.yml
sed -i 's/%%/%/g' app/config/parameters.yml

echo "**** we create phpunit.xml ****"
if [ ! -f app/phpunit.xml ]; then
    cp app/phpunit.xml.dist app/phpunit.xml
fi

echo "** we add config in AppKernel **"
if ! grep -q "getContainerBaseClass" app/AppKernel.php; then
    sed  -i -e "/registerContainerConfiguration/r $DIR/artifacts/appkernel.txt" -e //N app/AppKernel.php
fi

echo "** we modify config.yml **"
if ! grep -q "assets_version: v1_0_0" app/config/config.yml; then
    sed -i "/engines/a \        assets_version: v1_0_0 " app/config/config.yml
    sed -i '/translator/c\    translator:      { fallback: "%locale%" }' app/config/config.yml
fi

echo "****  we add in .gitignore file default values from symfony project ****"
if ! grep -q "www.gitignore.io" .gitignore; then
    curl -L -s https://www.gitignore.io/api/symfony >> .gitignore
fi

echo "**** we add env variables ****"
sudo bash -c "cat << EOT > /etc/profile.d/$PLATEFORM_PROJET_NAME_LOWER.sh
# env vars for SFYNFONY platform
export SYMFONY__DATABASE__NAME__ENV__$PLATEFORM_PROJET_NAME_UPPER=$DATABASE_NAME;
export SYMFONY__DATABASE__USER__ENV__$PLATEFORM_PROJET_NAME_UPPER=root;
export SYMFONY__DATABASE__PASSWORD__ENV__$PLATEFORM_PROJET_NAME_UPPER=pacman;
export SYMFONY__TEST__DATABASE__NAME__ENV__$PLATEFORM_PROJET_NAME_UPPER=$DATABASE_NAME_TEST;
export SYMFONY__TEST__DATABASE__USER__ENV__$PLATEFORM_PROJET_NAME_UPPER=root;
export SYMFONY__TEST__DATABASE__PASSWORD__ENV__$PLATEFORM_PROJET_NAME_UPPER=pacman;

EOT"
. /etc/profile.d/${PLATEFORM_PROJET_NAME_LOWER}.sh
printenv |grep "__ENV__$PLATEFORM_PROJET_NAME_UPPER" # list of all env
# unset envName # delete a env var

echo "**** we add test config for database ****"
if ! grep -q "doctrine" app/config/config_test.yml; then
    echo "$(cat $DIR/artifacts/config_test.yml)" >> app/config/config_test.yml
fi

echo "**** On déclare le socket Unix de PHP-FPM pour que Nginx puisse passer les requêtes PHP via fast_cgi ****"
if [ ! -f /etc/nginx/conf.d/php5-fpm.conf ];
then
sh -c "cat > /etc/nginx/conf.d/php5-fpm.conf" <<EOT
upstream php5-fpm-sock {  
    server unix:/var/run/php5-fpm.sock;  
}
EOT
fi

echo "**** we create the virtualhost ****"
mkdir -p /tmp
cat <<EOT >/tmp/$PLATEFORM_PROJET_NAME
#upstream php5-fpm-sock {  
#    server unix:/var/run/php5-fpm.sock;  
#}

server {
    set \$website_root "$INSTALL_USERWWW/$PLATEFORM_PROJET_NAME/web";
    set \$default_env  "app_dev.php";

    listen 80;

    # Server name being used (exact name, wildcards or regular expression)
    server_name dev.$PLATEFORM_PROJET_NAME_LOWER.local;

    # Document root, make sure this points to your Symfony2 /web directory
    root \$website_root;

    # Don't show the nginx version number, a security best practice
    server_tokens off;

    # charset
    charset utf-8;

    # Gzip
    gzip on;
    gzip_min_length 1100;
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;
    gzip_disable "MSIE [1-6]\.";
    gzip_proxied any; 
    gzip_comp_level 6;
    gzip_buffers 16 8k; 
    gzip_http_version 1.1; 

    # Logging
    access_log off; 
    log_not_found off; 
    #error_log  /var/log/nginx/sfynx-error.log;

    # Cache information about frequently accessed files
    open_file_cache max=2000 inactive=20s; 
    open_file_cache_valid 60s; 
    open_file_cache_min_uses 5; 
    open_file_cache_errors off;

    # Adjust client timeouts
    client_max_body_size 50M; 
    client_body_buffer_size 1m; 
    client_body_timeout 15; 
    client_header_timeout 15; 
    keepalive_timeout 2 2; 
    send_timeout 15; 
    sendfile on; 
    tcp_nopush on; 
    tcp_nodelay on;

    # Adjust output buffers
    fastcgi_buffers 256 16k; 
    fastcgi_buffer_size 128k; 
    fastcgi_connect_timeout 3s; 
    fastcgi_send_timeout 120s; 
    fastcgi_read_timeout 120s; 
    fastcgi_busy_buffers_size 256k; 
    fastcgi_temp_file_write_size 256k; 
    reset_timedout_connection on; 
    #server_names_hash_bucket_size 100;

    location / {
        # try to serve file directly, fallback to rewrite
        try_files \$uri @rewriteapp;

    }

    location @rewriteapp {
        rewrite ^(.*)\$ /\$default_env/\$1 last;
    }

    # Pass the PHP scripts to FastCGI server
    location ~ ^/(app|app_dev|app_test|config)\.php(/|\$) {
        fastcgi_pass php5-fpm-sock;
        fastcgi_split_path_info ^(.+\.php)(/.*)\$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param  HTTPS off;
        # fastcgi_param PHP_VALUE "auto_prepend_file=/websites/xhprof/external/header.php \n auto_append_file=/websites/xhprof/external/footer.php";
        fastcgi_param SYMFONY__DATABASE__NAME__ENV__${PLATEFORM_PROJET_NAME_UPPER} $DATABASE_NAME;
        fastcgi_param SYMFONY__DATABASE__USER__ENV__${PLATEFORM_PROJET_NAME_UPPER} root;
        fastcgi_param SYMFONY__DATABASE__PASSWORD__ENV__${PLATEFORM_PROJET_NAME_UPPER} pacman;
        fastcgi_param SYMFONY__TEST__DATABASE__NAME__ENV__${PLATEFORM_PROJET_NAME_UPPER} $DATABASE_NAME_TEST;
        fastcgi_param SYMFONY__TEST__DATABASE__USER__ENV__${PLATEFORM_PROJET_NAME_UPPER} root;
        fastcgi_param SYMFONY__TEST__DATABASE__PASSWORD__ENV__${PLATEFORM_PROJET_NAME_UPPER} pacman;
    }

    # Nginx Cache Control for Static Files
    location ~* \.(jpg|jpeg|gif|png|css|js|ico|xml)\$ { 
        access_log        off; 
        log_not_found     off; 
        expires           360d; 
    } 

    # Prevent (deny) Access to Hidden Files with Nginx
    location ~ /\. { 
        access_log off; 
        log_not_found off; 
        deny all; 
    }


   location /phpmyadmin {
               root /usr/share/;
               index index.php index.html index.htm;
               location ~ ^/phpmyadmin/(.+\.php)\$ {
                       try_files \$uri =404;
                       root /usr/share/;
                       fastcgi_pass php5-fpm-sock;
                       fastcgi_index index.php;
                       fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                       include /etc/nginx/fastcgi_params;
               }
               location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))\$ {
                       root /usr/share/;
               }
   }

   location /phpMyAdmin {
            rewrite ^/* /phpmyadmin last;
   }

}

server {
    set \$website_root "$INSTALL_USERWWW/$PLATEFORM_PROJET_NAME/web";
    set \$default_env  "app_test.php";

    listen 80;

    # Server name being used (exact name, wildcards or regular expression)
    server_name test.$PLATEFORM_PROJET_NAME_LOWER.local;

    # Document root, make sure this points to your Symfony2 /web directory
    root \$website_root;

    # Don't show the nginx version number, a security best practice
    server_tokens off;

    # charset
    charset utf-8;

    # Gzip
    gzip on;
    gzip_min_length 1100;
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;
    gzip_disable "MSIE [1-6]\.";
    gzip_proxied any; 
    gzip_comp_level 6;
    gzip_buffers 16 8k; 
    gzip_http_version 1.1; 

    # Logging
    access_log off; 
    log_not_found off; 
    #error_log  /var/log/nginx/sfynx-error.log;

    # Cache information about frequently accessed files
    open_file_cache max=2000 inactive=20s; 
    open_file_cache_valid 60s; 
    open_file_cache_min_uses 5; 
    open_file_cache_errors off;

    # Adjust client timeouts
    client_max_body_size 50M; 
    client_body_buffer_size 1m; 
    client_body_timeout 15; 
    client_header_timeout 15; 
    keepalive_timeout 2 2; 
    send_timeout 15; 
    sendfile on; 
    tcp_nopush on; 
    tcp_nodelay on;

    # Adjust output buffers
    fastcgi_buffers 256 16k; 
    fastcgi_buffer_size 128k; 
    fastcgi_connect_timeout 3s; 
    fastcgi_send_timeout 120s; 
    fastcgi_read_timeout 120s; 
    fastcgi_busy_buffers_size 256k; 
    fastcgi_temp_file_write_size 256k; 
    reset_timedout_connection on; 
    #server_names_hash_bucket_size 100;

    location / {
        # try to serve file directly, fallback to rewrite
        try_files \$uri @rewriteapp;

    }

    location @rewriteapp {
        rewrite ^(.*)\$ /\$default_env/\$1 last;
    }

    # Pass the PHP scripts to FastCGI server
    location ~ ^/(app|app_dev|app_test|config)\.php(/|\$) {
        fastcgi_pass php5-fpm-sock;
        fastcgi_split_path_info ^(.+\.php)(/.*)\$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param  HTTPS off;
        # fastcgi_param PHP_VALUE "auto_prepend_file=/websites/xhprof/external/header.php \n auto_append_file=/websites/xhprof/external/footer.php";
        fastcgi_param SYMFONY__DATABASE__NAME__ENV__${PLATEFORM_PROJET_NAME_UPPER} $DATABASE_NAME;
        fastcgi_param SYMFONY__DATABASE__USER__ENV__${PLATEFORM_PROJET_NAME_UPPER} root;
        fastcgi_param SYMFONY__DATABASE__PASSWORD__ENV__${PLATEFORM_PROJET_NAME_UPPER} pacman;
        fastcgi_param SYMFONY__TEST__DATABASE__NAME__ENV__${PLATEFORM_PROJET_NAME_UPPER} $DATABASE_NAME_TEST;
        fastcgi_param SYMFONY__TEST__DATABASE__USER__ENV__${PLATEFORM_PROJET_NAME_UPPER} root;
        fastcgi_param SYMFONY__TEST__DATABASE__PASSWORD__ENV__${PLATEFORM_PROJET_NAME_UPPER} pacman;
    }

    # Nginx Cache Control for Static Files
    location ~* \.(jpg|jpeg|gif|png|css|js|ico|xml)\$ { 
        access_log        off; 
        log_not_found     off; 
        expires           360d; 
    } 

    # Prevent (deny) Access to Hidden Files with Nginx
    location ~ /\. { 
        access_log off; 
        log_not_found off; 
        deny all; 
    }


   location /phpmyadmin {
               root /usr/share/;
               index index.php index.html index.htm;
               location ~ ^/phpmyadmin/(.+\.php)\$ {
                       try_files \$uri =404;
                       root /usr/share/;
                       fastcgi_pass php5-fpm-sock;
                       fastcgi_index index.php;
                       fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                       include /etc/nginx/fastcgi_params;
               }
               location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))\$ {
                       root /usr/share/;
               }
   }

   location /phpMyAdmin {
            rewrite ^/* /phpmyadmin last;
   }

}

server {
    set \$website_root "$INSTALL_USERWWW/$PLATEFORM_PROJET_NAME/web";
    set \$default_env  "app.php";

    listen 80;

    # Server name being used (exact name, wildcards or regular expression)
    server_name prod.$PLATEFORM_PROJET_NAME_LOWER.local;

    # Document root, make sure this points to your Symfony2 /web directory
    root \$website_root;

    # Don't show the nginx version number, a security best practice
    server_tokens off;

    # charset
    charset utf-8;

    # Gzip
    gzip on;
    gzip_min_length 1100;
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;
    gzip_disable "MSIE [1-6]\.";
    gzip_proxied any; 
    gzip_comp_level 6;
    gzip_buffers 16 8k; 
    gzip_http_version 1.1; 

    # Logging
    access_log off; 
    log_not_found off; 
    #error_log  /var/log/nginx/sfynx-error.log;

    # Cache information about frequently accessed files
    open_file_cache max=2000 inactive=20s; 
    open_file_cache_valid 60s; 
    open_file_cache_min_uses 5; 
    open_file_cache_errors off;

    # Adjust client timeouts
    client_max_body_size 50M; 
    client_body_buffer_size 1m; 
    client_body_timeout 15; 
    client_header_timeout 15; 
    keepalive_timeout 2 2; 
    send_timeout 15; 
    sendfile on; 
    tcp_nopush on; 
    tcp_nodelay on;

    # Adjust output buffers
    fastcgi_buffers 256 16k; 
    fastcgi_buffer_size 128k; 
    fastcgi_connect_timeout 3s; 
    fastcgi_send_timeout 120s; 
    fastcgi_read_timeout 120s; 
    fastcgi_busy_buffers_size 256k; 
    fastcgi_temp_file_write_size 256k; 
    reset_timedout_connection on; 
    #server_names_hash_bucket_size 100;

    location / {
        # try to serve file directly, fallback to rewrite
        try_files \$uri @rewriteapp;

    }

    location @rewriteapp {
        rewrite ^(.*)\$ /\$default_env/\$1 last;
    }

    # Pass the PHP scripts to FastCGI server
    location ~ ^/(app|app_dev|app_test|config)\.php(/|\$) {
        fastcgi_pass php5-fpm-sock;
        fastcgi_split_path_info ^(.+\.php)(/.*)\$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param  HTTPS off;
        # fastcgi_param PHP_VALUE "auto_prepend_file=/websites/xhprof/external/header.php \n auto_append_file=/websites/xhprof/external/footer.php";
        fastcgi_param SYMFONY__DATABASE__NAME__ENV__${PLATEFORM_PROJET_NAME_UPPER} $DATABASE_NAME;
        fastcgi_param SYMFONY__DATABASE__USER__ENV__${PLATEFORM_PROJET_NAME_UPPER} root;
        fastcgi_param SYMFONY__DATABASE__PASSWORD__ENV__${PLATEFORM_PROJET_NAME_UPPER} pacman;
        fastcgi_param SYMFONY__TEST__DATABASE__NAME__ENV__${PLATEFORM_PROJET_NAME_UPPER} $DATABASE_NAME_TEST;
        fastcgi_param SYMFONY__TEST__DATABASE__USER__ENV__${PLATEFORM_PROJET_NAME_UPPER} root;
        fastcgi_param SYMFONY__TEST__DATABASE__PASSWORD__ENV__${PLATEFORM_PROJET_NAME_UPPER} pacman;
    }

    # Nginx Cache Control for Static Files
    location ~* \.(jpg|jpeg|gif|png|css|js|ico|xml)\$ { 
        access_log        off; 
        log_not_found     off; 
        expires           360d; 
    } 

    # Prevent (deny) Access to Hidden Files with Nginx
    location ~ /\. { 
        access_log off; 
        log_not_found off; 
        deny all; 
    }


   location /phpmyadmin {
               root /usr/share/;
               index index.php index.html index.htm;
               location ~ ^/phpmyadmin/(.+\.php)\$ {
                       try_files \$uri =404;
                       root /usr/share/;
                       fastcgi_pass php5-fpm-sock;
                       fastcgi_index index.php;
                       fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                       include /etc/nginx/fastcgi_params;
               }
               location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))\$ {
                       root /usr/share/;
               }
   }

   location /phpMyAdmin {
            rewrite ^/* /phpmyadmin last;
   }

}
EOT
echo "**** we create the symbilic link ****"
sudo rm /etc/nginx/sites-enabled/$PLATEFORM_PROJET_NAME
sudo rm /etc/nginx/sites-available/$PLATEFORM_PROJET_NAME
sudo mv /tmp/$PLATEFORM_PROJET_NAME /etc/nginx/sites-available/$PLATEFORM_PROJET_NAME
sudo ln -s /etc/nginx/sites-available/$PLATEFORM_PROJET_NAME /etc/nginx/sites-enabled/$PLATEFORM_PROJET_NAME

echo "**** we add host in the /etc/hosts file ****"
if ! grep -q "dev.$PLATEFORM_PROJET_NAME_LOWER.local" /etc/hosts; then
    echo "# Adding hostname of the $PLATEFORM_PROJET_NAME project" |sudo tee --append /etc/hosts
    echo "127.0.0.1    dev.$PLATEFORM_PROJET_NAME_LOWER.local" |sudo tee --append /etc/hosts
    echo "127.0.0.1    test.$PLATEFORM_PROJET_NAME_LOWER.local" |sudo tee --append /etc/hosts
    echo "127.0.0.1    prod.$PLATEFORM_PROJET_NAME_LOWER.local" |sudo tee --append /etc/hosts
    echo "   " |sudo tee --append /etc/hosts
fi

echo "**** we restart nginx server ****"
sudo service nginx restart

echo "**** we delete bin-dir config to have the default value egal to 'vendor/bin' ****"
if [ -f "composer.json" ]; then
     sed -i '/bin-dir/d' composer.json
     rm composer.lock
fi

if [ ! -f composer.phar ]; then
    echo "**** we install/update the composer file ****"
    wget https://getcomposer.org/composer.phar -O ./composer.phar
    #curl -sS https://getcomposer.org/installer |sudo php -- --install-dir=/usr/local/bin --filename=composer
else
    echo "update composer.phar"
    php composer.phar self-update    
fi

echo "**** we create database ****"
php app/console doctrine:database:create
php app/console doctrine:database:create --env=test

echo "**** we install bundles and their dependancies ****"
$DIR/doctrine/doctrine-extension.sh "$DIR" "$PLATEFORM_VERSION"
$DIR/jms/jms.sh "$DIR" "$PLATEFORM_VERSION"
$DIR/fosuser/fosuser.sh "$DIR" "$PLATEFORM_VERSION" "$DOMAINE" "$FOSUSER_PREFIX" "$MYAPP_BUNDLE_NAME" "$MYAPP_PREFIX"
$DIR/site/install.sh "$DIR" "$PLATEFORM_VERSION" "$DOMAINE"  "$MYAPP_BUNDLE_NAME" "$MYAPP_PREFIX"
$DIR/fosrest/fosrest.sh "$DIR" "$PLATEFORM_VERSION" "$DOMAINE"
#$DIR/qa/qa.sh "$DIR" "$PLATEFORM_VERSION"

echo "**** we lauch the composer ****"
composer install --no-interaction
echo "**** Generating optimized autoload files ****"
composer dump-autoload --optimize

echo "**** we remove cache files ****"
rm -rf app/cache/*
rm -rf app/logs/*

echo "**** we set all necessary permissions ****"
# Utiliser l'ACL sur un système qui supporte chmod +a
#HTTPDUSER=`ps aux |grep -E '[a]pache|[h]ttpd|[_]www|[w]ww-data|[n]ginx' |grep -v root |head -1 |cut -d\  -f1`
#sudo chmod +a "$HTTPDUSER allow delete,write,append,file_inherit,directory_inherit" app/cache app/logs
#sudo chmod +a "`whoami` allow delete,write,append,file_inherit,directory_inherit" app/cache app/logs

# Utiliser l'ACL sur un système qui ne supporte pas chmod +a
#HTTPDUSER=`ps aux |grep -E '[a]pache|[h]ttpd|[_]www|[w]ww-data|[n]ginx' |grep -v root |head -1 |cut -d\  -f1`
HTTPDUSER=$(ps -o user= -p $$ |awk '{print $1}')
sudo setfacl -R -m u:"$HTTPDUSER":rwX -m u:`whoami`:rwX app/cache app/logs
sudo setfacl -dR -m u:"$HTTPDUSER":rwX -m u:`whoami`:rwX app/cache app/logs

# sans utiliser ACL
## Définit une permission 0775 aux fichiers
#echo "umask(0002);" |sudo tee --prepend app/console
#echo "umask(0002);" |sudo tee --prepend web/app_dev.php
#echo "umask(0002);" |sudo tee --prepend web/app.php
## Définit une permission 0777 aux fichiers
#echo "umask(0000);" |sudo tee --prepend app/console
#echo "umask(0000);" |sudo tee --prepend web/app_dev.php
#echo "umask(0000);" |sudo tee --prepend web/app.php

sudo usermod -aG www-data $HTTPDUSER
sudo chown -R $HTTPDUSER:www-data $INSTALL_USERWWW/$PLATEFORM_PROJET_NAME
sudo chmod -R 0755 $INSTALL_USERWWW/$PLATEFORM_PROJET_NAME
sudo chmod -R 0775 app/config/parameters.yml
sudo chmod -R 0775 app/cache
sudo chmod -R 0775 app/logs
sudo chmod -R 0775 web/uploads

echo "**** we install assetic and asset files ****"
php app/console assets:install
php app/console assetic:dump
php app/console cache:clear

echo "** we detect mapping error execute **"
php app/console doctrine:mapping:info
