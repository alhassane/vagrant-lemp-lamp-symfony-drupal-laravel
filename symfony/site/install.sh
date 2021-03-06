#!/bin/sh

DIR=$1
PLATEFORM_VERSION=$2
DOMAINE=$3
MYAPP_BUNDLE_NAME=$4
MYAPP_PREFIX=$5

DOMAINE_LOWER=$(echo $DOMAINE |awk '{print tolower($0)}') # we lower the string
MYAPP_BUNDLE_NAME_LOWER=$(echo $MYAPP_BUNDLE_NAME |awk '{print tolower($0)}') # we lower the string

echo "**** ApplicationBundle creation ****"

echo "** we generate ${DOMAINE}${MYAPP_BUNDLE_NAME}Bundle with User and Group entities **"
if [ ! -d src/${DOMAINE}/${MYAPP_BUNDLE_NAME}Bundle ]; then
    php app/console generate:bundle --namespace="${DOMAINE}/${MYAPP_BUNDLE_NAME}Bundle" --bundle-name="${DOMAINE}${MYAPP_BUNDLE_NAME}Bundle" --format=annotation --structure --dir=src --no-interaction
fi

echo "** we modify artifatcs **"
cp -R $DIR/site/exo1/* src/${DOMAINE}/${MYAPP_BUNDLE_NAME}Bundle
find src/${DOMAINE}/${MYAPP_BUNDLE_NAME}Bundle/* -type f -exec sed -i  "s/MyApp\\\SiteBundle/${DOMAINE}\\\\${MYAPP_BUNDLE_NAME}Bundle/g" {} \;
find src/${DOMAINE}/${MYAPP_BUNDLE_NAME}Bundle/* -type f -exec sed -i  "s/MyAppSite/${DOMAINE}${MYAPP_BUNDLE_NAME}/g" {} \;
find src/${DOMAINE}/${MYAPP_BUNDLE_NAME}Bundle/* -type f -exec sed -i  "s/myappsite/${DOMAINE_LOWER}${MYAPP_BUNDLE_NAME_LOWER}/g" {} \;
find src/${DOMAINE}/${MYAPP_BUNDLE_NAME}Bundle/* -type f -exec sed -i  "s/myapp/${DOMAINE_LOWER}/g" {} \;
find src/${DOMAINE}/${MYAPP_BUNDLE_NAME}Bundle/* -type f -exec sed -i  "s/MyAppAuthBundle/${DOMAINE}AuthBundle/g" {} \;
mv src/${DOMAINE}/${MYAPP_BUNDLE_NAME}Bundle/MyAppSiteBundle.php src/${DOMAINE}/${MYAPP_BUNDLE_NAME}Bundle/${DOMAINE}${MYAPP_BUNDLE_NAME}Bundle.php
mv src/${DOMAINE}/${MYAPP_BUNDLE_NAME}Bundle/DependencyInjection/MyAppSiteExtension.php src/${DOMAINE}/${MYAPP_BUNDLE_NAME}Bundle/DependencyInjection/${DOMAINE}${MYAPP_BUNDLE_NAME}Extension.php
sed -i "s/XmlFileLoader/YamlFileLoader/g" src/${DOMAINE}/${MYAPP_BUNDLE_NAME}Bundle/DependencyInjection/${DOMAINE}${MYAPP_BUNDLE_NAME}Extension.php
sed -i "s/services.xml/services.yml/g" src/${DOMAINE}/${MYAPP_BUNDLE_NAME}Bundle/DependencyInjection/${DOMAINE}${MYAPP_BUNDLE_NAME}Extension.php

echo "** we add routing **"
if ! grep -q "${DOMAINE}${MYAPP_BUNDLE_NAME}Bundle/Resources/config/routing.yml" app/config/routing.yml; then
    echo "$(cat $DIR/site/addRoutingExo1.yml)" >> app/config/routing.yml
    sed -i "s/MyAppSiteBundle/${DOMAINE}${MYAPP_BUNDLE_NAME}Bundle/g" app/config/routing.yml
    sed -i "s/myapp/${MYAPP_PREFIX}/g" app/config/routing.yml
fi

echo "we add parameters"
if ! grep -q "switch_language_authorized" app/config/parameters.yml; then
    echo "    switch_language_authorized: true" >> app/config/parameters.yml
    echo "    all_locales: ['fr', 'en']" >> app/config/parameters.yml
    echo "    switch_language_authorized: true" >> app/config/parameters.yml.dist
    echo "    all_locales: ['fr', 'en']" >> app/config/parameters.yml.dist
fi

echo "**** we create phpunit.xml ****"
if [ ! -f app/phpunit.xml ]; then
    cp app/phpunit.xml.dist app/phpunit.xml
fi

echo "** we create datatable in database **"
rm -rf app/cache/*
php app/console doctrine:schema:create --env=dev --process-isolation  -v
php app/console doctrine:schema:update --env=dev --force
php app/console doctrine:schema:create --env=test --process-isolation  -v
php app/console doctrine:schema:update --env=test --force
