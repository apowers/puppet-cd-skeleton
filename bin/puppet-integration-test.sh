#!/bin/bash
# This script runs in a new Vagrant instance.
#

ROLE=$1

docker run --rm -t -v $(pwd):/remote --privileged -i phusion/baseimage /sbin/my_init -- /remote/bin/provision-standalone.sh ${ROLE}
