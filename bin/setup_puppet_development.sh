#!/bin/bash
# Install tools needed for developing and testing puppet modules.

# apowers, 2014.09.02 - initial write

PKGS='ruby-dev libxslt-dev libxml2-dev lxc-docker'
GEMS='beaker bundler puppet_facts puppet-lint puppet-syntax rspec-puppet beaker-rspec rake puppetlabs_spec_helper'

# Keyserver and repo for docker
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys
echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list

echo force-confold >> /etc/dpkg/dpkg.cfg.d/force_confold;
DEBIAN_FRONTEND=noninteractive;
RUNLEVEL=1

# update and install packages
/usr/bin/apt-get update;
/usr/bin/apt-get -qq -y install $PKGS
unset RUNLEVEL

/usr/bin/gem install $GEMS --no-rdoc --no-ri

# Download and install vagrant
vagrant_pkg='vagrant_1.6.3_x86_64.deb'
/usr/bin/wget -O /tmp/${vagrant_pkg} https://dl.bintray.com/mitchellh/vagrant/${vagrant_pkg}
/usr/bin/dpkg -i /tmp/${vagrant_pkg}

# Passwordless SSH access to docker with insecure-key
# https://github.com/phusion/baseimage-docker#login_ssh
wget -O ~/.ssh/docker_insecure.key https://github.com/phusion/baseimage-docker/raw/master/image/insecure_key
chmod 400 ~/.ssh/docker_insecure.key
echo << EOF
Put the following into your ~/.ssh/config file, replacing the "Host" address with your docker network.

# For Beaker Docker
Host 169.254.97.?
  User root
  IdentityFile ~/.ssh/docker_insecure.key

EOF

