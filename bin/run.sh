#!/bin/bash
# Run one or more spec tests in a docker image.
# All arguments are assumed to be roles to test.
# It assumes that `/mnt/remote` is mapped to the root of the puppet repository.
# This also assumes that build.sh has already been run to install required packages.

# First copy files for testing,
# Then, for each role:
#   Set a local fact to define that role.
#   Run `puppet apply -t /etc/puppet/manifests/site.pp`
#   Run `rake spec:base`
#   Run `rake spec:$role`
#   If NRPE tests are available, run those.

ROLES=$@
export HOME='/root'

if [[ ! -d /mnt/remote ]] ; then
        echo Start this from the root of the puppet repository:
        echo 'docker run --rm --privileged -v $(pwd):/mnt/remote -ti centos-baseimage:6 /sbin/run_init -- /mnt/remote/tests/build.sh [role(s)]'
        echo 'OR'
        echo 'docker run --rm --privileged -v $(pwd):/mnt/remote -ti centos-baseimage:7 /sbin/run_init systemd.unit=baseimage-shell.service'
        exit 1
fi

function set_hostgroup {
    CLUSTER='Cluster'
    HADOOP=''
    CLIENT=''
    GROUP=''
    OSVER=''
    case $ROLE in
        auth-*)
            CLUSTER=''
            GROUP='LDAPServers'
            ;;
        backup-*)
            OSVER='6'
            HADOOP='Hadoop'
            ;;
        cnc-001)
            OSVER='6'
            HADOOP='Hadoop'
            ;;
        cnc-*) ;;
        datasci-*)
            OSVER='6'
            HADOOP='Hadoop'
            CLIENT='Client'
            GROUP='Datasci'
            ;;
        ft-*) ;;
        hadoop-*)
            OSVER='6'
            HADOOP='Hadoop'
            ;;
        jump-*) ;;
        lb-*) ;;
        mirror-*) ;;
        modelfactor-*)
            OSVER='6'
            HADOOP='Hadoop'
            CLIENT='Client'
            GROUP='Datasci'
            ;;
        nfs-*) ;;
        proxy-*) ;;
        puppet-*) ;;
        smtp-*) ;;
        sql-*) ;;
        upton-*)
            OSVER='6'
            HADOOP='Hadoop'
            CLIENT='Client'
            ;;
        webapp-*)
            OSVER='6'
            HADOOP='Hadoop'
            CLIENT='Client'
            GROUP='Webapp'
            ;;
        *) ;;
    esac

    export facter_cluster=${CLUSTER}
    export facter_hadoop=${HADOOP}
    export facter_client=${CLIENT}
    export facter_group=${GROUP}

    # Save to facts.d
#    echo '#!/bin/sh' > /etc/facter/facts.d/role
    echo "echo cluster=${CLUSTER}"  > /etc/facter/facts.d/cluster
    echo "echo hadoop=${HADOOP}"    > /etc/facter/facts.d/hadoop
    echo "echo client=${CLIENT}"    > /etc/facter/facts.d/client
    echo "echo group=${GROUP}"      > /etc/facter/facts.d/group
    chmod +x /etc/facter/facts.d/*
}

function puppet_abort {
    echo '***********************'
    echo '* Puppet Run Failed.  *'
    echo '* Aborting Tests!     *'
    echo '***********************'
    exit 2
}

function check_osversion {
    if [[ -f '/etc/os-release' ]]; then
        source /etc/os-release
    else
        VERSION_ID=$(cat /etc/system-release-cpe|cut -f5 -d:)
    fi

    if [[ "$OSVER" != '' && "$OSVER" != "$VERSION_ID" ]] ; then
        echo '**********************************'
        echo "* Role Requrires CentOS $OSVER.       *"
        echo "* Skipping Tests for $ROLE. "
        echo '**********************************'
        return 1
    fi
    return 0
}

function install_puppet_files {
    echo Install Puppet Files
    rsync -a --delete /mnt/remote/* /etc/puppet/. ; chown -R puppet /etc/puppet
    cp /mnt/remote/test/puppet.conf /etc/puppet/puppet.conf

    if [[ -r /etc/puppet/Puppetfile ]] ; then
            echo Install modules via R10K/Librarian
            /usr/bin/gem install r10k ${GEM_OPTS}
            cd /etc/puppet
            /usr/local/bin/r10k puppetfile install
    fi

    #if [[ -r /etc/puppet/hiera.yaml ]] ; then
    #        /usr/bin/gem install hiera-eyaml ${GEM_OPTS}
    #fi

    echo 'Sync Puppet Modules and test Manifests'
    rsync -a /mnt/remote/modules/* /etc/puppet/modules/
    mkdir -p /etc/puppet/hiera
    mkdir -p /etc/facter/facts.d
    cp /mnt/remote/test/manifests/test_strut.pp /etc/puppet/manifests/.
    rsync -a /mnt/remote/test/hiera/* /etc/puppet/hiera/
    cp /mnt/remote/test/hiera.yaml /etc/puppet/hiera.yaml
    chown -R puppet:puppet /etc/puppet

    # Set defaults
    echo '#!/bin/sh' > /etc/facter/facts.d/role
    echo 'echo role=none'  >> /etc/facter/facts.d/role
}

install_puppet_files
set_hostgroup

####
# Test each role
####
for ROLE in ${ROLES} ; do
    echo Testing Role $ROLE

    export facter_role=${ROLE}
    echo '#!/bin/sh' > /etc/facter/facts.d/role
    echo "echo role=${ROLE}"  >> /etc/facter/facts.d/role

    set_hostgroup

    check_osversion || continue

    puppet apply --detailed-exitcodes /etc/puppet/manifests
    [[ $? == 1 || $? > 2 ]] && puppet_abort

    cd /mnt/remote/test
    rake spec:Default   ; EX+=$?
    if [[ $CLUSTER ]];then rake spec:${CLUSTER} ; EX=$(($EX+$?)) ;fi
    if [[ $HADOOP ]] ;then rake spec:${HADOOP} ; EX=$(($EX+$?)) ;fi
    if [[ $CLIENT ]] ;then rake spec:${CLIENT} ; EX=$(($EX+$?)) ;fi
    if [[ $GROUP ]]  ;then rake spec:${GROUP}  ; EX=$(($EX+$?)) ;fi
    if [[ $ROLE ]]   ;then rake spec:$ROLE     ; EX=$(($EX+$?)) ;fi

    if [[ -x /usr/bin/check_nrpe.sh ]] ; then
      echo Running NRPE Checks
      /usr/bin/check_nrpe.sh
    fi
done

# If no roles are defined, just test base.
if [[ "$ROLES" == "" ]] ; then
        echo 'Testing Default (no role or host group)'

    puppet apply --detailed-exitcodes /etc/puppet/manifests
    [[ $? == 1 || $? > 2 ]] && puppet_abort

    cd /mnt/remote/test
    rake spec:Default ; EX+=$?
    rake spec:Cluster ; EX=$(($EX+$?))

    if [[ -x /usr/bin/check_nrpe.sh ]] ; then
      echo Running NRPE Checks
      /usr/bin/check_nrpe.sh
    fi
fi

exit $EX
