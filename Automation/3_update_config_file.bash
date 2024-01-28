#!/bin/bash

while getopts 'p:rh' opt
do
  case "$opt" in
    p) projectId="$OPTARG";;
    r) reset='-r';;
    ?|h)
      echo "Usage: $(basename $0) -p projectId [-r] [-h]"
      echo "       -r will restore to previous policy"
      exit 1
      ;;
  esac
done

#node=( node0.mdb.com node1.mdb.com node2.mdb.com )
node=( $( cat ${projectId}_hostnames ) )
num=${#node[@]}

n=0
while [ $n -lt $num ]
do

  printf "Working on node $n: ${node[$n]} \n"
  # edit Bind User Bind Password
  ssh ${node[$n]} \
    bash -c "cd /data; \
      cp automation-mongod.conf old.conf; \
      cat automation-mongod.conf \
        | sed -e \"s/queryPassword:.*/queryPassword: ${bindPassword}/\" -e \"s/queryUser:.*/queryUser: ${bindUser}/\"  > new.conf; \
      mv new.conf automation-mongod.conf "
  ssh ${node[$n]} \
    bash -c "grep query /data/automation-mongod.conf " 
  n=$((n+1))
done
