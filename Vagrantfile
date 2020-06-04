# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

VAGRANTFILE_API_VERSION ||= "2"
confDir = $confDir ||= File.expand_path(File.dirname(__FILE__))

require File.expand_path(File.dirname(__FILE__) + '/scripts/localDev.rb')

Vagrant.require_version '>= 2.2.9'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    settings = YAML::load(File.read(confDir + "/LocalDev.yaml"))

    LocalDev.configure(config, settings)

     config.vm.provision "shell", path: "scripts/system-setup.sh", privileged: true, keep_color: true
     config.vm.provision "shell", path: "scripts/user-setup.sh", privileged: false, keep_color: true
end