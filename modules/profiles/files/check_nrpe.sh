#!/bin/bash

# Run all the test scripts in a directory.
# Used to perform functional tests on a system after a puppet run.
# Exits clean if no errors are reported. Reports errors if they are encountered.

# apowers, 2014.07.10 - initial write
# apowers, 2014.09.02 - convert from pandora checks to nrpe checks

CHECK_DIR=${1:-'/etc/nagios/nrpe.d'}

#eXit status.
X=0

for test in $CHECK_DIR/* ; do
  if [[ -f $test && -x $test ]] ; then
    T=$(/bin/grep = $test|/usr/bin/cut -d'=' -f2)
    R=$(/bin/sh -c "$T") && continue
    X=$(($X+$?))
    echo COMMAND: $T
    echo FAILED:
    echo $R
  fi
done

exit $X
