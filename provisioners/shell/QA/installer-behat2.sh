#!/bin/sh

mkdir -p ~/.composer

# http://www.frandieguez.com/blog/2014/10/easy-way-to-install-php-qa-tools/

#Add lines to the beginning and the end of the huge file
if ! grep -q "~/.composer/vendor/bin" ~/.profile; then
sudo ed -s ~/.profile << 'EOF'
0a
#prepend these lines to the beginning
.
$a

#append these lines to the end
# set your $PATH environment variable to include it
export PATH=$PATH:~/.composer/vendor/bin
.
w
EOF
fi

#Reload bash's .profile without logging out and back in again
. ~/.profile

# Install composer based tools
cat > ~/.composer/composer.json <<EOF
{
    "require": {
        "behat/behat": "2.4.*@stable",
        "behat/mink": "1.4@stable",
        "behat/mink-goutte-driver": "*",
        "behat/mink-selenium-driver": "*",
        "behat/mink-selenium2-driver": "*",
        "behat/mink-extension": "*",
        "behat/mink-sahi-driver": "*",
        "phpunit/phpunit": "3.7.*"

    },
    "minimum-stability": "dev",
    "config": {
        "bin-dir": "vendor/bin/"
    }
}
EOF
curl -sS https://getcomposer.org/installer |sudo php -- --install-dir=/usr/local/bin --filename=composer
/usr/local/bin/composer global install
chown -R $SUDO_USER.$SUDO_USER ~/.composer



