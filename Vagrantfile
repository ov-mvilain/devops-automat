#  -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Vagrantfile for ansible-common-role

Vagrant.configure("2") do |config|
  # config.vm.network 'forwarded_port', guest: 80, host: 8080
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.ssh.insert_key = false
  config.vm.boot_timeout = 120
  config.vm.provider :virtualbox do |vb|
    #vb.gui = true
    vb.memory = '1024'
  end
  # provision on all machines to allow ssh w/o checking
  config.vm.provision "shell", inline: <<-SHELLALL
    echo "...disabling CheckHostIP..."
    sed -i.orig -e "s/#   CheckHostIP yes/CheckHostIP no/" /etc/ssh/ssh_config
    sed -i -e "s/.*PermitRootLogin.*/PermitRootLogin yes/" /etc/ssh/ssh_config
#     for i in /etc/sysconfig/network-scripts/ifcfg-eth1 /etc/sysconfig/network-scripts/ifcfg-enp0s8; do
#       if [ -e ${i} ]; then echo "...displaying ${i}..."; cat ${i}; fi
#     done
  SHELLALL

  config.vm.define "a2" do |a2|
    a2.vm.box = "bento/amazonlinux-2"
    a2.ssh.insert_key = false
    a2.vm.network 'private_network', ip: '192.168.10.190'
    a2.vm.hostname = 'a2.test'
    a2.vm.provision "shell", inline: <<-SHELL
      amazon-linux-extras install epel ansible2=2.8 python3.8
      yum-config-manager --enable epel
      yum install -y git
    SHELL
    a2.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yaml"
      ansible.inventory_path = "./inventory"
      # ansible.verbose = "v"
      # ansible.raw_arguments = [""]
    end
  end

  # mac10.15 box for testing MacOS Cataline
  # https://github.com/ramsey/macos-vagrant-box
  config.vm.define "m15" do |m15|
    m15.vm.box = "ramsey/macos-catalina"
    m15.ssh.insert_key = false
    m15.vm.network 'private_network', ip: '192.168.10.15'
    m15.vm.hostname = 'm15.test'
    m15.vm.provision "shell", inline: <<-SHELL
    #
    SHELL
    m15.vm.provision "ansible" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "site.yaml"
      ansible.inventory_path = "./inventory"
      # ansible.verbose = "v"
      # ansible.raw_arguments = [""]
    end
  end

end
