#!/bin/bash
# This script runs in a new Vagrant instance.
#

mkdir -p /etc/facter/facts.d

cat > /etc/facter/facts.d/role <<EOF
#!/bin/sh
echo role=cd_demo
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
    PKGS='ruby-dev libxslt-dev libxml2-dev'

    PUPPET_URL="http://apt.puppetlabs.com";
    PUPPET_REPO="puppetlabs-release-$(lsb_release -c -s).deb";
    DEBIAN_FRONTEND=noninteractive;
    RUNLEVEL=1
    APT_OPTS='-qq -y'
    echo force-confold >> /etc/dpkg/dpkg.cfg.d/force_confold;
    export DEBIAN_FRONTEND=noninteractive
    echo 'Dpkg::Options{"--force-confdef";"--force-confold";}' >> /etc/apt/apt.conf.d/local
    /usr/bin/apt-get -qq -y update;
    /usr/bin/apt-get -qq -y install wget;
    /usr/bin/wget -O /tmp/$PUPPET_REPO $PUPPET_URL/$PUPPET_REPO 2>&1 >/dev/null;
    /usr/bin/dpkg -i /tmp/$PUPPET_REPO;
    /usr/bin/apt-get -qq -y update;
    # Remove old managers before installing what we actually want.
    echo Install Packages
    /usr/bin/apt-get -qq -y install ${PKGS}
    echo Install Puppet
    /usr/bin/apt-get -qq -y purge chef chef-zero puppet puppet-common ruby-hiera facter;
    /usr/bin/apt-get -qq -y install puppet facter git
    unset RUNLEVEL

  ;;
  CentOS)
    PUPPET_URL="http://yum.puppetlabs.com/el/6/products/x86_64";
#TODO: find a way to automatically detecte this repo name. (hint: look in the spec_helper_acceptance.rp examples for puppet_pe
    PUPPET_REPO="puppetlabs-release-6-7.noarch.rpm";
    /usr/bin/wget -O /tmp/$PUPPET_REPO $PUPPET_URL/$PUPPET_REPO 2>&1 >/dev/null;
    rpm -ivh /tmp/$PUPPET_REPO
    /usr/bin/yum -y -q install puppet
  ;;
  FreeBSD)
    portinstall puppet
  ;;
esac

echo Install Gems
# puppet-rspec has issues with rspec-core 3.0.0+ (2014.09.04)
/usr/bin/gem install rspec -v '<3.0.0' ${GEM_OPTS}

GEMS='beaker beaker-rspec bundler hiera-eyaml puppet_facts puppet-lint puppet-syntax r10k rake rspec-puppet puppetlabs_spec_helper'
/usr/bin/gem install ${GEMS} ${GEM_OPTS}

echo Install Puppet files
rsync -a /remote/* /etc/puppet/. ; chown -R puppet /etc/puppet
cp /remote/puppet.conf /etc/puppet/puppet.conf

echo Install modules via R10K/Librarian
cd /etc/puppet
/usr/local/bin/r10k puppetfile install

puppet agent --enable

puppet apply /etc/puppet/manifests/site.pp

echo 'To re-run tests:'
#echo 'rsync -a /vagrant/* /etc/puppet/. ; chown -R puppet /etc/puppet ; puppet apply /etc/puppet/manifests/site.pp'
echo '/remote/puppet-apply.sh [role]'

