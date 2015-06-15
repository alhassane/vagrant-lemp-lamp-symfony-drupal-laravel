# -*- mode: ruby -*-
# vi: set ft=ruby :
 
# Load settings
personalization = File.expand_path("../provisioners/parameters", __FILE__)
load personalization
 
# Requierements
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"
 
#
# Vagrant configure
#
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    # Setup box
    config.vm.box = $box_name
    config.vm.box_url = $box_url
    #config.ssh.private_key_path = "~/.ssh/my_vagrant_key"

    # Set Hostname
    config.vm.host_name = $vm_hostname

    # Set the default project share
    config.vm.synced_folder ".",  $vm_group, id: "vagrant-root", :nfs => true
    config.vm.synced_folder "./", $vm_www_point, create: false, type: "nfs"
 
    # Configure Virtualbox
    config.vm.provider "virtualbox" do |v|
      v.gui = $vm_gui
      v.name = $vm_name
      #v.name = (0...8).map { (65 + rand(26)).chr }.join
      v.customize ["modifyvm", :id, "--groups",          $vm_group,
                                    "--cpuexecutioncap", $vm_cpu_cap,
                                    "--memory",          $vm_memory,
                                    "--cpus",            $vm_cpus]
    end
 
    # Create a forwarded port mapping which allows access to a specific port within the machine from a port on the host machine.
    config.vm.network :forwarded_port, guest: $pf_mysql, host: $pf_mysql_localhost,  auto_correct: true
    config.vm.network :forwarded_port, guest: $pf_http, host: $pf_http_localhost,  auto_correct: true

    # Create a private network, which allows host-only access to the machine using a specific IP.
    config.vm.network :private_network, ip: $vm_ip
     
    #This next bit fixes the 'stdin is not a tty' error when shell provisioning Ubuntu boxes
    #if there a line that only consists of 'mesg n' in /root/.profile, replace it with 'tty -s && mesg n'
    config.vm.provision :shell,    
    :inline => "(grep -q -E '^mesg n$' /root/.profile && sed -i 's/^mesg n$/tty -s \\&\\& mesg n/g' /root/.profile && echo 'Ignore the previous error about stdin not being a tty. Fixing it now...') || exit 0;"

    #config.vm.provision :shell, :inline => "sed -i 's/^mesg n$/tty -s \\&\\& mesg n/g' /root/.profile"

    # Shell provisioning
    config.vm.provision "shell" do |s|
        s.path = "provisioners/shell/bootstrap.sh"
        s.args = [$vm_www_point, $box_distrib, $plateform_install_name, $plateform_install_type, $plateform_install_version, $plateform_projet_name, $plateform_projet_git, $plateform_username_git, $vm_www_point]
        s.privileged = true
    end

    #config.vm.provision :shell, :inline => "sh /vagrant/provisioners/shell/pc/installer-pc.sh; sh /vagrant/provisioners/shell/lemp/installer-lemp.sh;"

end


#if Vagrant.has_plugin? 'vagrant-omnibus'
#  # Set Chef version for Omnibus
#  config.omnibus.chef_version = :latest
#else
#  raise Vagrant::Errors::VagrantError.new,
#    "vagrant-omnibus missing, please install the plugin:\n" +
#    "vagrant plugin install vagrant-omnibus"
#end

#config.vm.synced_folder ".", $vm_www_point, :create => false, type: "rsync",
#                                              rsync__exclude: [
#                                                ".buildpath",
#                                                ".git",
#                                                ".project",
#                                                ".settings"
#                                              ]
#config.vm.synced_folder "/Volumes/Documents/projets/test", "/web/www", create: true, group: "www-data", owner: "vagrant", mount_options: ["dmode=775,fmode=664"]


#    config.vm.define "serveur1" do |conf|
#        conf.vm.box = "d7"
#        conf.vm.box_url = "http://192.168.0.46:8080/Debian7-64.box"
#        conf.ssh.private_key_path = "~/.ssh/my_vagrant_key"
#        conf.vm.host_name = "serveur1"
# 
#        conf.vm.provider "virtualbox" do |vb|
#            vb.customize ["modifyvm", :id, "--memory", "512"]
#            vb.customize ["modifyvm", :id, "--name", "serveur1"]
#        end
#    end


# liste of all vm
## vagrant global-status
# destroy a vm by id
## vagrant destroy <id>

# list of all vagrant box
## vagrant box list
# delete vagrant box
## vagrant box --clean <BoxName>

# list of all virtualbox vms
## VBoxManage list vms
# delete virtualbox vm
## VBoxManage unregistervm --delete "Vagrant"

# vagrant up --debug
## vagrant reload --provision

# create box from existing vm
## vagrant package --base SPECIFIC_NAME_FOR_VM --output /yourfolder/OUTPUT_BOX_NAME.box

# add ubuntu box
## vagrant package –-base Ubuntu-14.04-64-Desktop  # Create Vagrant Base Box
## vagrant box add Ubuntu-14.04-64-Desktop package.box # install vagrant box
## vagrant init Ubuntu-14.04-64-Desktop

# chown -R <USERNAME> /<YOUR-WEBSITES-DIRECTORY>/.vagrant/machines/
# chown -R <USERNAME> /<YOUR-HOME-DIRECTORY>/.vagrant.d
# rm  /<YOUR-HOME-DIRECTORY>/.vagrant.d/data/lock.fpcollision.lock

# http://stackoverflow.com/questions/25652769/should-vagrant-require-sudo-for-each-command
# https://github.com/Varying-Vagrant-Vagrants/VVV/issues/261
# http://stackoverflow.com/questions/27670076/permission-denied-error-for-vagrant


# rm /home/etienne/.vagrant.d/data/lock.fpcollision.lock
# find /home/etienne/.vagrant.d -exec ls -al {} \;
# rm -rf /home/etienne/.vagrant.d

# SSH
## vagrant plugin install vagrant-vbguest
## sometime error like this
##Running provisioner: file...
##Failed to upload a file to the guest VM via SCP due to a permissions
##error. This is normally because the SSH user doesn't have permission
##to write to the destination location. Alternately, the user running
##Vagrant on the host machine may not have permission to read the file.
## solution>>>>  vagrant ssh =>  sudo chmod -R 777 /tmp => exit
