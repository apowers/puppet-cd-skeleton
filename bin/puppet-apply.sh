#!/bin/bash
[[ $1 != '' ]] && export facter_role=$1
rsync -a /remote/* /etc/puppet/. ; chown -R puppet: /etc/puppet
puppet apply -t /etc/puppet/manifests/site.pp

echo Running NRPE Checks
/usr/bin/check_nrpe.sh
