#!/bin/bash

# Run all the test scripts in a directory.
# Used to perform functional tests on a system after a puppet run.
# Exits clean if no errors are reported. Reports errors if they are encountered.

# apowers, 2014.07.10 - initial write
# apowers, 2014.09.09 - better output

CHECK_DIR=${1:-'/etc/nagios/nrpe.d'}

#eXit status.
X=0
red='\E[0;31m'
NC='\E[0m'
F=''

for test in $CHECK_DIR/* ; do
  if [[ -f $test ]] ; then
    T=$(/bin/grep = $test|/usr/bin/cut -d'=' -f2)
    R=$(/bin/sh -c "$T")
    Z=$?
    X=$(($X+$Z))
    if [[ $Z != 0 ]];then
      F=$(echo $F ; echo $T)
      echo -en ${red}
    fi
    echo $T
    echo ${R}
    echo -en ${NC}
  fi
done
if [[ $X != 0 ]] ; then
echo -en ${red}
echo ERROR: Some checks failed:
echo $F
echo -en ${NC}
fi
exit $X
