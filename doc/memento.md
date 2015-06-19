# liste of all vm
vagrant global-status

# destroy a vm by id
vagrant destroy <id>

# list of all vagrant box
vagrant box list

# delete vagrant box
vagrant box --clean <BoxName>

# list of all virtualbox vms
VBoxManage list vms

# delete virtualbox vm
VBoxManage unregistervm --delete "Vagrant"

# vagrant up --debug
vagrant reload --provision

# create box from existing vm
vagrant package --base SPECIFIC_NAME_FOR_VM --output /yourfolder/OUTPUT_BOX_NAME.box
vagrant box add OUTPUT_BOX_NAME /yourfolder/OUTPUT_BOX_NAME.box
vagrant init OUTPUT_BOX_NAME

# add ubuntu box
vagrant package –-base Ubuntu-14.04-64-Desktop  # Create Vagrant Base Box
vagrant box add Ubuntu-14.04-64-Desktop package.box # install vagrant box
vagrant init Ubuntu-14.04-64-Desktop

# permission
chown -R <USERNAME> /<YOUR-WEBSITES-DIRECTORY>/.vagrant/machines/
chown -R <USERNAME> /<YOUR-HOME-DIRECTORY>/.vagrant.d

#errors type
http://stackoverflow.com/questions/25652769/should-vagrant-require-sudo-for-each-command
https://github.com/Varying-Vagrant-Vagrants/VVV/issues/261
http://stackoverflow.com/questions/27670076/permission-denied-error-for-vagrant
rm  /<YOUR-HOME-DIRECTORY>/.vagrant.d/data/lock.fpcollision.lock

# rm /home/etienne/.vagrant.d/data/lock.fpcollision.lock
# find /home/etienne/.vagrant.d -exec ls -al {} \;
# rm -rf /home/etienne/.vagrant.d

# SSH
vagrant plugin install vagrant-vbguest
sometime error like this
Running provisioner: file...
Failed to upload a file to the guest VM via SCP due to a permissions
error. This is normally because the SSH user doesn't have permission
to write to the destination location. Alternately, the user running
Vagrant on the host machine may not have permission to read the file.
solution>>>>  vagrant ssh =>  sudo chmod -R 777 /tmp => exit


#
VBoxManage list vms
VBoxManage showvminfo "BoxName"

#