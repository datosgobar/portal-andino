# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

BRANCH = ENV['BRANCH'] || 'master'

INSTALL_DEPENDENCIES = true
INSTALL_APP = true
UPDATE_APP = !INSTALL_APP

COMPOSE_VERSION = "1.13.0"
DOCKER_ENGINE_VERSION =

IP = "192.168.23.10"

$script_install = <<SCRIPT
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update
sudo apt-get install -y docker-ce=17.06.2~ce-0~ubuntu

sudo su -c "curl -L https://github.com/docker/compose/releases/download/#{COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
sudo chmod +x /usr/local/bin/docker-compose

SCRIPT

$script = <<SCRIPT
sudo -E python ./install.py --error_email admin@example.com \
            --site_host #{IP} \
            --database_user db_user \
            --database_password db_pass \
            --datastore_user data_db_user \
            --datastore_password data_db_pass \
            --branch #{BRANCH}

SCRIPT

$update = <<SCRIPT
sudo -E python ./update.py --branch #{BRANCH}
SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "bento/ubuntu-16.04"
  config.vm.define "andino" do |web|
    web.vm.network "private_network", ip: IP
    config.vm.provision "file", source: "install/install.py", destination: "install.py"
    config.vm.provision "file", source: "install/update.py", destination: "update.py"
    if INSTALL_DEPENDENCIES
        config.vm.provision "shell", inline: $script_install
    end
    if INSTALL_APP
        config.vm.provision "shell", inline: $script
    end
    if UPDATE_APP
        config.vm.provision "shell", inline: $update
    end
  end

end