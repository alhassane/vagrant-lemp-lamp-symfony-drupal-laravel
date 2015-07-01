#!/bin/bash
DIR=$1
DISTRIB=$2
INSTALL_USERWWW=$3
source $DIR/provisioners/shell/env.sh

echo "Removing Windows newlines on Linux (sed vs. awk)"
#find $DIR/provisioners/* -type f -exec dos2unix {} \;

echo "***** We set permmissions for all scriptshell"
mkdir -p /tmp
sudo chmod -R 777 /tmp
sudo chmod -R +x $DIR
sudo chmod -R 777 $DIR
sudo chmod 755 /etc/apt/sources.list

echo "***** First we copy own sources.list to box *****"
if [ -f $DIR/provisioners/shell/etc/apt/$DISTRIB/sources.list ];
then
    cp $DIR/provisioners/shell/etc/apt/$DISTRIB/sources.list /etc/apt/sources.list
    apt-get -y update > /dev/null
    apt-get -y dist-upgrade > /dev/null
fi
sudo dpkg --configure -a

echo "***** Second we update the system *****"
apt-get -y install build-essential > /dev/null
apt-get -y update > /dev/null
apt-get -y dist-upgrade > /dev/null

echo "***** Add vagrant to www-data group *****"
sudo usermod -aG www-data vagrant
#chown -R ${INSTALL_USERNAME}:${INSTALL_USERGROUP} ${INSTALL_USERWWW}/${PROJET_NAME}

echo "***** Provisionning PC *****"
$DIR/provisioners/shell/SWAP/installer-swap.sh "$DIR" # important to allow the composer to have enough memory
$DIR/provisioners/shell/pc/installer-pc.sh "$DIR" "$DISTRIB"

echo "***** Provisionning LEMP *****"
$DIR/provisioners/shell/lemp/installer-lemp.sh "$DIR"

echo "**** we install/update the composer file ****"
#wget https://getcomposer.org/composer.phar -O ./composer.phar
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

#$DIR/provisioners/shell/QA/installer-phpqatools.sh "$DIR"

echo "***** Provisionning JACKRABBIT *****"
$DIR/provisioners/shell/jackrabbit/installer-jackrabbit.sh "$DIR" "$INSTALL_USERWWW"

echo "***** Provisionning SOLR *****"
if [ -f $DIR/provisioners/shell/solr/installer-solr-$DISTRIB.sh ];
then
    #$DIR/provisioners/shell/solr/installer-solr-$DISTRIB.sh $DIR
    $DIR/provisioners/shell/solr/installer.sh "$DIR"
    #echo "pas solr"
fi

echo "***** Provisionning JACKRABBIT *****"
if [ -f $DIR/provisioners/shell/xhprof/installer-xhprof-$DISTRIB.sh ];
then
    $DIR/provisioners/shell/xhprof/installer-xhprof-$DISTRIB.sh
fi

echo "**** we install plateforms ****"
$DIR/provisioners/shell/plateform/installer-all-plateforms.sh "$DIR" "$DISTRIB" "$INSTALL_USERWWW"

echo "***** End we clean-up the system *****"
sudo apt-get -y autoremove > /dev/null
sudo apt-get -y clean > /dev/null
sudo apt-get -y autoclean > /dev/null

echo "Finished provisioning."
