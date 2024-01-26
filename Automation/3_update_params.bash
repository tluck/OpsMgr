#!/bin/bash

# direct connect to each node in the ReplicaSet
cs=(  mongodb://dbAdmin:Mongodb1@node0.mdb.com:27107/  \
      mongodb://dbAdmin:Mongodb1@node1.mdb.com:27107/  \
      mongodb://dbAdmin:Mongodb1@node2.mdb.com:27107/  \
   )

num=${#cs[@]}

query1='db.adminCommand({setParameter: 1, ldapQueryUser:     "cn=abcde,dc=example,dc=org" });'
query2='db.adminCommand({setParameter: 1, ldapQueryPassword: "bindPassword"               });'
query3='db.adminCommand({getParameter: 1, ldapQueryUser:     ""                           });'
query4='db.adminCommand({getParameter: 1, ldapQueryPassword: ""                           });'

n=0
while [ $n -lt $num ]
do

printf "Working on replica $n: ${cs[$n]} \n"
mongosh --quiet ${cs[$n]} <<EOF
${query1}
${query2}
${query3}
${query4}
EOF

n=$((n+1))
done
