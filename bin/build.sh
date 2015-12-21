#!/bin/bash
# Run one or more spec tests in a docker image.
# All arguments are assumed to be roles to test.
# It assumes that `/mnt/remote` is mapped to the root of the puppet repository.

# First install testing requirements:
# - puppet
# - ruby-devel
# - serverspec
# - puppetlabs_spec_helper
# - r10k (optional)
# - hiera (optional)
# Then, call run.sh to run the tests.l

# Use the value in the parameter or the one in the environment.
if [[ -z $@ ]] ; then
    ROLES=$TEST
else
    ROLES=$@
fi

export HOME='/root'

if [[ ! -d /mnt/remote ]] ; then
        echo Start this from the root of the puppet repository:
        echo 'docker run --rm --privileged -v $(pwd):/mnt/remote -ti centos-baseimage /sbin/run_init -- /mnt/remote/tests/build.sh [role(s)]'
        echo 'OR'
        echo 'docker run --rm --privileged -v $(pwd):/mnt/remote -ti centos-baseimage:7 /sbin/run_init systemd.unit=baseimage-shell.service'
        exit 1
fi

####
# Install Puppet
####
if [[ -f '/etc/os-release' ]]; then
    source /etc/os-release
else
    ID=$(cat /etc/issue | head -1 | cut -f1 -d " ")
fi

case $ID in
  ubuntu|debian|Ubuntu|Debian)

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

  centos|redhat|CentOS|RedHat)
    yum install -y -q wget rsync ruby-devel redhat-lsb-core bind-utils
    [[ -z "$VERSION_ID" ]] && VERSION_ID=6
#TODO: find a way to automatically detecte this repo name. (hint: look in the spec_helper_acceptance.rp examples for puppet_pe
#    PUPPET_URL="http://yum.puppetlabs.com/el/${VERSION_ID}/products/x86_64";
#    PUPPET_REPO="puppetlabs-release-7-11.noarch.rpm";
    PUPPET_URL="http://yum.puppetlabs.com";
    PUPPET_REPO="puppetlabs-release-el-${VERSION_ID}.noarch.rpm";
    /usr/bin/wget -O /tmp/$PUPPET_REPO $PUPPET_URL/$PUPPET_REPO 2>&1 >/dev/null;
    rpm -ivh /tmp/$PUPPET_REPO
    /usr/bin/yum -y -q install puppet
  ;;
  *)
    echo "Unsupported Operating System $OSFAMILY"
    exit 3
esac


####
# Setup the environment
####

# override lookup for the repo mirror
/usr/bin/host env.corp.ad.local || /bin/echo "10.161.16.40 env.corp.ad.local" >> /etc/hosts

mkdir -p /etc/facter/facts.d
echo '#!/bin/sh' > /etc/facter/facts.d/environment
echo "echo environment=testing" >> /etc/facter/facts.d/environment

GEM_OPTS='--quiet --no-rdoc --quiet --no-ri'

/usr/bin/gem install rake serverspec puppetlabs_spec_helper ${GEM_OPTS}
#/usr/bin/gem install rake serverspec puppetlabs_spec_helper deep_merge ${GEM_OPTS}

echo ******************************************* $ROLES

# Run the tests
/mnt/remote/test/run.sh $ROLES

exit $?
