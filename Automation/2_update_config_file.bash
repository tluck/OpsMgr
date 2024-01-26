#!/bin/bash

node=( node0.mdb.com node1.mdb.com node2.mdb.com )
num=${#node[@]}

n=0
while [ $n -lt $num ]
do

  printf "Working on node $n: ${node[$n]} \n"
  # edit Bind Password
  ssh ${node[$n]} \
    bash -c "cd /data; cp automation-mongod.conf old.conf; cat automation-mongod.conf |sed -e 's/queryPassword:.*/queryPassword: abcdepassword/' > new.conf ; mv new.conf automation-mongod.conf "
  # edit Bind User
  ssh ${node[$n]} \
    bash -c "cd /data; cat automation-mongod.conf |sed -e 's/queryUser:.*/queryUser: cn=abcde,dc=example,dc=org/' > new.conf ; mv new.conf automation-mongod.conf ; diff /data/*conf; ls -l /data/*conf; grep query /data/automation-mongod.conf "

  n=$((n+1))
done
