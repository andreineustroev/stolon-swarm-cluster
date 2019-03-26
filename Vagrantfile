# -*- mode: ruby -*-
# vi: set ft=ruby :

$num_instances = 3
$instance_name_prefix = 'host'

Vagrant.configure("2") do |config|
  ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'
  config.vm.box = "generic/ubuntu1804"
  config.vm.box_version = "1.9.6"
  # config.ssh.insert_key = false

  config.vm.provider :libvirt do |libvirt|
    libvirt.uri = 'qemu:///system'
    # libvirt.host = "192.168.226.113"
    # libvirt.username = "aneustroev"
    # libvirt.connect_via_ssh = true
    libvirt.storage_pool_name = "home"
    libvirt.driver = "kvm"
    libvirt.memory = 1024
    libvirt.cpus = 2
    libvirt.volume_cache = "unsafe"
  end
  (1..$num_instances).each do |i|
    config.vm.define vm_name = "#{$instance_name_prefix}#{i}" do |vm|
      vm.vm.provision "shell", inline: <<-SHELL
        hostnamectl set-hostname "#{$instance_name_prefix}#{i}"
      SHELL
    end
  end
  config.vm.synced_folder "~/projects/stolon", "/home/vagrant/", type: "rsync"
  config.vm.provision "shell", path: "ks.sh"
  config.vm.provision "shell", inline: <<-SHELL
    # ip route del default via 192.168.121.1
    # ip route add default via 192.168.30.1
    mkdir -p /home/vagrant/.ssh
    echo "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBOVi48hCzyIrZUsOi1Y/rkFMQQn07Db9lISUT8Ph6AZPqZXKWJBA/stsp01g3bHq+5yUhjD0tE/InYqtiILXEGE= Neustroev Andrei <aneustroev@naumen.ru>" > /home/vagrant/.ssh/authorized_keys
  SHELL
end

