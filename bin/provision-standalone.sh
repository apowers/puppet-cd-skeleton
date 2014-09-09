#!/bin/bash
# This script runs in a new Vagrant instance.
#

[[ -r './puppet.conf' ]] && ( echo 'Must be run from puppet project root.' ; exit 1 )

ROLE=$1
export facter_role=${ROLE}

mkdir -p /etc/facter/facts.d

echo '#!/bin/sh' > /etc/facter/facts.d/role
echo "echo role=${ROLE}" >> /etc/facter/facts.d/role

echo '#!/bin/sh' > /etc/facter/facts.d/environment
echo "echo environment=testing" >> /etc/facter/facts.d/environment

chmod +x /etc/facter/facts.d/*

GEM_OPTS='--quiet --no-rdoc --quiet --no-ri'
OSFAMILY=$(cat /etc/issue | head -1 | cut -f1 -d " ")
case $OSFAMILY in
  Ubuntu|Debian)

    PUPPET_URL="http://apt.puppetlabs.com";
    PUPPET_REPO="puppetlabs-release-$(lsb_release -c -s).deb";
    DEBIAN_FRONTEND=noninteractive;
    RUNLEVEL=1
    APT_OPTS='-qq -y'
    echo force-confold >> /etc/dpkg/dpkg.cfg.d/force_confold;
    echo 'Dpkg::Options{"--force-confdef";"--force-confold";}' >> /etc/apt/apt.conf.d/local
    /usr/bin/apt-get ${APT_OPTS} update 2>&1 >/dev/null;
    /usr/bin/apt-get ${APT_OPTS} install wget;
    /usr/bin/wget -O /tmp/$PUPPET_REPO $PUPPET_URL/$PUPPET_REPO 2>&1 >/dev/null;
    /usr/bin/dpkg -i /tmp/$PUPPET_REPO;
    /usr/bin/apt-get ${APT_OPTS} update 2>&1 >/dev/null;
    # Remove old managers before installing what we actually want.
    echo Install Puppet
    /usr/bin/apt-get ${APT_OPTS} purge chef chef-zero puppet puppet-common ruby-hiera facter;
    /usr/bin/apt-get ${APT_OPTS} install puppet facter git
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

/usr/bin/gem install r10k ${GEM_OPTS}
/usr/bin/gem install hiera-eyaml ${GEM_OPTS}
/usr/bin/gem install rake ${GEM_OPTS}

echo Install Puppet files
rsync -a /remote/* /etc/puppet/. ; chown -R puppet /etc/puppet
cp /remote/puppet.conf /etc/puppet/puppet.conf

echo Install modules via R10K/Librarian
cd /etc/puppet
/usr/local/bin/r10k puppetfile install

rsync -a /remote/modules/* /etc/puppet/modules/. ; chown -R puppet: /etc/puppet
puppet apply -t /etc/puppet/manifests/site.pp

echo Running NRPE Checks
if [[ -x /usr/bin/check_nrpe.sh ]] ; then
  /usr/bin/check_nrpe.sh
else
  echo "ERROR: No /usr/bin/check_nrpe.sh script found. Assume all tests failed."
  exit -1
fi

