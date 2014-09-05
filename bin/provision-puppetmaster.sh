#!/bin/bash
# Script to build a puppet master on an Ubuntu or Debian system.
# Requirements: An IP address, hostname, and valid network configuration.
#
#. Install the puppetlabs repositories.
#. Setup git.
#. Checkout the puppet repository.
#. Install the puppetmaster package.
#. Install puppetmaster dependencies: postgresql, ngnix, etc.
#. Start the puppetmaster service.
#
# Many parts of this scipt are borrowed from:
# https://github.com/seattle-biomed/bootstrap-linux/blob/master/bootstrap-linux
# https://github.com/pkhamre/puppetmaster-bootstrap/blob/master/puppetmaster-bootstrap
#
# ChangeLog
# 2013.05.06 - apowers: Initial write
# 2013.05.07 - apowers: bugfixes, mostly
# 2013.11.01 - apowers: bufgixes with service setup
# 2014.09.03 - apowers: cleanup for puppet-cd-skeleton

PATH='/bin:/sbin:/usr/bin:/usr/sbin'

if [ "`/usr/bin/id -u`" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

puppet_pkg='puppetmaster'
puppet_conf='puppet.conf'

PUPPET_URL='http://apt.puppetlabs.com/'
DISTRIB_CODENAME=`awk -F= '/^DISTRIB_CODENAME/ { print $2 }' /etc/lsb-release`
PUPPET_REPO="puppetlabs-release-$DISTRIB_CODENAME.deb"
POSTGRESQL_VERSION='9.1'

# Make apt-get install really really quietly.
APT_OPTS='-qq -y'
export DEBIAN_FRONTEND=noninteractive
echo 'Dpkg::Options{"--force-confdef";"--force-confold";}' >> /etc/apt/apt.conf.d/local
GEM_OPTS='--no-rdoc --quiet --no-ri'

# Don't start services automatically
# echo no-triggers > /etc/dpkg/dpkg.cfg.d/custom

echo Setup the puppetlabs apt repository
curl --silent ${PUPPET_URL}/pubkey.gpg | apt-key add - > /dev/null
/usr/bin/wget -O /tmp/$PUPPET_REPO $PUPPET_URL/$PUPPET_REPO
/usr/bin/dpkg -i /tmp/$PUPPET_REPO
/usr/bin/apt-get update

echo Install and setup git.
/usr/bin/apt-get -y install git
/usr/bin/ssh-keyscan git.sbri.org > /etc/ssh/ssh_known_hosts
mkdir -p /root/.ssh
cp /vagrant/files/puppetmaster/git_key /root/.ssh/git_key
cp /vagrant/files/puppetmaster/ssh_config /root/.ssh/config
chmod 400 /root/.ssh/*

echo Install puppetmaster
export RUNLEVEL=1
/usr/bin/apt-get ${APT_OPTS} install $puppet_pkg
unset RUNLEVEL

/usr/bin/gem install r10k ${GEM_OPTS}
/usr/bin/gem install hiera-eyaml ${GEM_OPTS}
/usr/bin/gem install rake ${GEM_OPTS}

echo Update to current development source for puppet and modules
rsync -a /vagrant/* /etc/puppet/.
chown -R puppet:0 /etc/puppet

echo Install modules via R10K/Librarian
cd /etc/puppet
/usr/local/bin/r10k puppetfile install

cat > /etc/facter/facts.d/role <<EOF
#!/bin/sh
echo 'role=puppetmaster'
EOF
chmod +x /etc/facter/facts.d/role

echo Start puppetmaster
/usr/sbin/ufw allow in 8140
cp /etc/puppet/puppet.conf.default /etc/puppet/puppet.conf
service puppetmaster start

puppet agent --enable
