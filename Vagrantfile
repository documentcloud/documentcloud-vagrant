# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  local_app_dir = "/Users/ted/dc/documentcloud/"
  app_root      = "/home/vagrant/documentcloud"
  rails_env     = "development"

  config.vm.box = "ubuntu/trusty64"
  config.vm.network :private_network, ip: "192.168.33.10"
  config.vm.synced_folder local_app_dir, app_root

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
  end

  script = <<-SHELL
    export USERNAME=vagrant;
    export RAILS_ENV=#{rails_env};
    sh /vagrant/scripts/base.sh;
SHELL

  config.vm.provision :shell, inline: script
end
