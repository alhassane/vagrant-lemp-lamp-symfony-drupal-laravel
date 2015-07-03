#!/bin/sh

# sudo wget -O /etc/yum.repos.d/sonar.repo http://downloads.sourceforge.net/project/sonar-pkg/rpm/sonar.repo
# sudo yum install sonar

# sudo deb http://downloads.sourceforge.net/project/sonarpkg/deb binary/
# sudo service sonar start
# sudo apt-get install sonar

echo "*** we download sonarqube  (http://www.sonarqube.org/downloads/) ***"
cd /etc
sudo wget http://downloads.sonarsource.com/sonarqube/sonarqube-5.1.1.zip
sudo unzip sonarqube-5.1.1.zip
sudo ln -s sonarqube-5.1.1 sonarqube
sudo ln -s /etc/sonarqube/bin/linux-x86-64/sonar.sh /etc/init.d/sonar
sudo mkdir -p /var/log/sonar
sudo ln -s /etc/sonarqube/logs/sonar.log /var/log/sonar/sonar.log
# We  edit the Sonar config file
#/etc/sonarqube/conf/sonar.properties to change the db to MySQL.

echo "*** We install the Sonar runner ***"
cd /etc
sudo wget http://repo1.maven.org/maven2/org/codehaus/sonar/runner/sonar-runner-dist/2.4/sonar-runner-dist-2.4.zip
sudo unzip sonar-runner-dist-2.4.zip
sudo ln -s sonar-runner-2.4 sonar-runner
sudo touch /etc/profile.d/sonar-runner.sh

echo "**** we add env variables ****"
sudo bash -c "cat << EOT > /etc/profile.d/sonar-runner.sh
#!/bin/bash

export SONAR_RUNNER_HOME=/etc/sonar-runner
export PATH=$PATH:$SONAR_RUNNER_HOME/bin

EOT"
. /etc/profile.d/sonar-runner.sh

echo "*** We start the SonarQube server ***"
#sudo service sonar console
sudo service sonar start

echo "*** We check sonar version ***"
sonar-runner -v

# step 0 - Go to http://localhost:9000 and cliquer sur "Log in".
#Login : admin
#Password : admin
# Go to Setting > System > Update center > Available pluginds > PHP plugin

# step 1 - create a sonarproject.properties file in directory root of your application
# step 2 - run in root directory the following command
#     $ /etc/sonar-runner/bin/sonar-runner
# step 3 - return to http://localhost:9000 and look at see the monitoring dashboard



