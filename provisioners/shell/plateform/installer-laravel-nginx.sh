#!/bin/bash
DIR=$1
DISTRIB=$2
INSTALL_USERWWW=$3
PLATEFORM_INSTALL_NAME=$4
PLATEFORM_INSTALL_TYPE=$5
PLATEFORM_INSTALL_VERSION=$6
PLATEFORM_PROJET_NAME=$7
PLATEFORM_PROJET_GIT=$8
DOMAINE=$9
MYAPP_BUNDLE_NAME=${10}
MYAPP_PREFIX=${11}
FOSUSER_PREFIX=${12}
source $DIR/provisioners/shell/env.sh
source $DIR/provisioners/shell/plateform/var.sh

#if var is empty
if [ -z "$PLATEFORM_PROJET_GIT" ]; then
    PLATEFORM_PROJET_GIT="git://github.com/laravel/laravel.git"
fi

echo "**** we create directories ****"
if [ ! -d $INSTALL_USERWWW ]; then
    mkdir -p $INSTALL_USERWWW
fi
cd $INSTALL_USERWWW

echo "we download all files of the $PLATEFORM_INSTALL_VERSION plateform"
if [ ! -d $PLATEFORM_PROJET_NAME ]; then
    git clone -b $PLATEFORM_INSTALL_VERSION --single-branch $PLATEFORM_PROJET_GIT $PLATEFORM_PROJET_NAME
    #mkdir -p $PLATEFORM_PROJET_NAME
fi
cd $PLATEFORM_PROJET_NAME
git checkout $PLATEFORM_INSTALL_VERSION

echo "****  we add in .gitignore file default values from laravel project ****"
if ! grep -q "www.gitignore.io" .gitignore; then
    curl -L -s https://www.gitignore.io/api/laravel >> .gitignore
fi

echo "**** we add env variables ****"
sudo bash -c "cat << EOT > /etc/profile.d/$PLATEFORM_PROJET_NAME_LOWER.sh
# env vars for SFYNFONY platform
export LARAVEL__DATABASE__NAME__ENV__$PLATEFORM_PROJET_NAME_UPPER=$DATABASE_NAME;
export LARAVEL__DATABASE__USER__ENV__$PLATEFORM_PROJET_NAME_UPPER=root;
export LARAVEL__DATABASE__PASSWORD__ENV__$PLATEFORM_PROJET_NAME_UPPER=pacman;
export LARAVEL__TEST__DATABASE__NAME__ENV__$PLATEFORM_PROJET_NAME_UPPER=$DATABASE_NAME_TEST;
export LARAVEL__TEST__DATABASE__USER__ENV__$PLATEFORM_PROJET_NAME_UPPER=root;
export LARAVEL__TEST__DATABASE__PASSWORD__ENV__$PLATEFORM_PROJET_NAME_UPPER=pacman;

EOT"
. /etc/profile.d/${PLATEFORM_PROJET_NAME_LOWER}.sh
printenv | grep "__ENV__$PLATEFORM_PROJET_NAME_UPPER" # list of all env
# unset envName # delete a env var

echo "**** we add test config for database ****"
if ! grep -q "doctrine" app/config/config_test.yml; then
    echo "$(cat $DIR/provisioners/shell/plateform/artifacts/config_test.yml)" >> app/config/config_test.yml
fi

echo "**** we create the virtualhost ****"
mkdir -p /tmp
cat <<EOT >/tmp/$PLATEFORM_PROJET_NAME
#upstream php5-fpm-sock {  
#    server unix:/var/run/php5-fpm.sock;  
#}

server {
    set \$website_root "$INSTALL_USERWWW/$PLATEFORM_PROJET_NAME/public";
    set \$default_env  "index.php";

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
    #error_log  /var/log/nginx/$PLATEFORM_PROJET_NAME-error.log;

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
    location ~ ^/(index)\.php(/|\$) {
        #include snippets/fastcgi-php.conf
        fastcgi_pass php5-fpm-sock;
        fastcgi_split_path_info ^(.+\.php)(/.*)\$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param  HTTPS off;
        # fastcgi_param PHP_VALUE "auto_prepend_file=/websites/xhprof/external/header.php \n auto_append_file=/websites/xhprof/external/footer.php";
        fastcgi_param LARAVEL__DATABASE__NAME__ENV__${PLATEFORM_PROJET_NAME_UPPER} $DATABASE_NAME;
        fastcgi_param LARAVEL__DATABASE__USER__ENV__${PLATEFORM_PROJET_NAME_UPPER} root;
        fastcgi_param LARAVEL__DATABASE__PASSWORD__ENV__${PLATEFORM_PROJET_NAME_UPPER} pacman;
        fastcgi_param LARAVEL__TEST__DATABASE__NAME__ENV__${PLATEFORM_PROJET_NAME_UPPER} $DATABASE_NAME_TEST;
        fastcgi_param LARAVEL__TEST__DATABASE__USER__ENV__${PLATEFORM_PROJET_NAME_UPPER} root;
        fastcgi_param LARAVEL__TEST__DATABASE__PASSWORD__ENV__${PLATEFORM_PROJET_NAME_UPPER} pacman;
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
    echo "# Adding hostname of the $PLATEFORM_PROJET_NAME project" | sudo tee --append /etc/hosts
    echo "127.0.0.1    dev.$PLATEFORM_PROJET_NAME_LOWER.local" | sudo tee --append /etc/hosts
    echo "   " | sudo tee --append /etc/hosts
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
    #curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
else
    echo "update composer.phar"
    php composer.phar self-update    
fi

echo "**** we lauch the composer ****"
sudo composer self-update
composer install --no-interaction
echo "**** Generating optimized autoload files ****"
composer dump-autoload --optimize 
