#!/bin/bash
# This script runs in a new Vagrant instance.
#

mkdir -p /etc/facter/facts.d

cat > /etc/facter/facts.d/role <<EOF
#!/bin/sh
echo role=none
EOF

cat > /etc/facter/facts.d/zone <<EOF
#!/bin/sh
echo zone=testing
EOF

chmod +x /etc/facter/facts.d/*

GEM_OPTS='--no-rdoc --quiet --no-ri'
OSFAMILY=$(cat /etc/issue | head -1 | cut -f1 -d " ")
case $OSFAMILY in
  Ubuntu|Debian)
    PUPPET_REPO="puppetlabs-release-$(lsb_release -c -s).deb";
    DEBIAN_FRONTEND=noninteractive;
    RUNLEVEL=1
    echo force-confold >> /etc/dpkg/dpkg.cfg.d/force_confold;
    /usr/bin/wget -O /tmp/$PUPPET_REPO "http://apt.puppetlabs.com/${PUPPET_REPO}" 2>&1 >/dev/null;
    /usr/bin/dpkg -i /tmp/$PUPPET_REPO;
    /usr/bin/apt-get -qq -y update;
    # Remove old managers before installing what we actually want.
    /usr/bin/apt-get -qq -y remove chef chef-zero puppet puppet-common ruby-hiera facter;
    /usr/bin/apt-get install -qq -y puppet facter git
    unset RUNLEVEL

    /usr/bin/gem install r10k ${GEM_OPTS}
    /usr/bin/gem install hiera-eyaml ${GEM_OPTS}
    /usr/bin/gem install rake ${GEM_OPTS}

  ;;
  CentOS)
    PUPPET_URL="http://yum.puppetlabs.com/el/6/products/x86_64";
#TODO: find a way to automatically detecte this repo name.
    PUPPET_REPO="puppetlabs-release-6-7.noarch.rpm";
    /usr/bin/wget -O /tmp/$PUPPET_REPO $PUPPET_URL/$PUPPET_REPO 2>&1 >/dev/null;
    rpm -ivh /tmp/$PUPPET_REPO
    /usr/bin/yum -y -q install puppet
  ;;
  FreeBSD)
    portinstall puppet
  ;;
esac

echo Install Puppet files
rsync -a /vagrant/* /etc/puppet/. ; chown -R puppet /etc/puppet
cp /vagrant/puppet.conf.default /etc/puppet/puppet.conf

puppet agent --enable

puppet agent -t

echo 'To re-run tests:'
echo 'puppet agent -t'
