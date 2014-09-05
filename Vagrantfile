# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Ubuntu publishes vagrant boxes: https://vagrantcloud.com/ubuntu
# For a list of other boxes: http://www.vagrantbox.es/
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Defaults
  config.vm.box = "puppetlabs/ubuntu-14.04-64-nocm"
  config.vm.box_url = 'https://vagrantcloud.com/puppetlabs/ubuntu-14.04-64-nocm/version/2/provider/virtualbox.box'
#  config.vm.box = "Ubuntu/trusty"
#  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
  config.vm.provision :shell, :inline=>'/vagrant/bin/vagrant-up.sh'

  # Alternate comercial providers are available, such as VMWare
  # http://www.vagrantup.com/vmware

  config.vm.define :ubuntu12_04 do |host|
    host.vm.box = "precise64"
    host.vm.box_url = "http://files.vagrantup.com/precise64.box"
    host.vm.host_name = "ubuntu-test.sbri.org"
    host.vm.network :private_network, ip: "169.254.96.19"
  end

  config.vm.define :ubuntu do |host|
    host.vm.host_name = "ubuntu-test.sbri.org"
    host.vm.network :private_network, ip: "169.254.96.20"
  end

  config.vm.define :centos do |host|
    host.vm.box = "centos-64-x64-vbox4210"
    host.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210-nocm.box'
    host.vm.network :private_network, ip: "169.254.96.21"
    host.vm.host_name = "centos-test.sbri.org"
  end

  config.vm.define :freebsd do |host|
    host.vm.box = "freebsd_amd64_ufs-9.1"
    host.vm.box_url = 'https://s3.amazonaws.com/vagrant_boxen/freebsd_amd64_ufs.box'
    host.vm.host_name = "freebsd-test.sbri.org"
    host.vm.network :private_network, ip: "169.254.96.22"
  end

  config.vm.define :debian do |host|
    host.vm.box = "debian-7.2.0"
    host.vm.host_name = "debian-test.sbri.org"
    host.vm.network :private_network, ip: "169.254.96.23"
    host.vm.box_url = 'https://dl.dropboxusercontent.com/u/197673519/debian-7.2.0.box'
  end

  # Development Puppet Master, latest
  # rsync -a --delete /vagrant/* /etc/puppet/.
  # rake puppet:validate:all
  # puppet parser validate
  #
  config.vm.define :puppetmaster do |host|
    host.vm.host_name = "puppet-test.sbri.org"
    host.vm.network :private_network, ip: "169.254.96.10"
    host.vm.network :forwarded_port, guest: 80, host: 50080
    host.vm.network :forwarded_port, guest: 443, host: 50443
    host.vm.network :forwarded_port, guest: 8080, host: 58080
    host.vm.provider(:virtualbox) { |v| v.customize ["modifyvm", :id, "--memory", "1024"] }
    host.vm.provision :shell, :path => "bin/puppetmaster-vagrant.sh"
  end

  config.vm.define :webhost do |host|
    host.vm.host_name = "webhost-test.sbri.org"
    host.vm.network :private_network, ip: "169.254.96.30"
    host.vm.network :forwarded_port, guest: 80, host: 10080
    host.vm.network :forwarded_port, guest: 443, host: 10443
    host.vm.network :forwarded_port, guest: 8000, host: 18000
    host.vm.network :forwarded_port, guest: 8080, host: 18080
  end

  config.vm.define :baseimage do |host|
    host.vm.provider 'docker' do |d|
      d.image           = 'phusion/baseimage'
      d.name            = 'baseimage'
      d.create_args     = ['-i','-t']
      d.cmd             = ['/sbin/my_init','-- /bin/bash -l']
      d.has_ssh         = true
      d.remains_running = false
    end
#    host.vm.synced_folder ".", "/etc/puppet", owner: 'puppet'
  end

end
