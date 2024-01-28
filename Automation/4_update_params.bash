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

# direct connect to each node in the ReplicaSet
node=( $( cat ${projectId}_hostnames ) )
num=${#node[@]}

cs=(  mongodb://${dbAuth}@${node[0]}:27017/  \
      mongodb://${dbAuth}@${node[1]}:27017/  \
      mongodb://${dbAuth}@${node[2]}:27017/  \
      mongodb://${dbAuth}@${node[3]}:27017/  \
      mongodb://${dbAuth}@${node[4]}:27017/  \
      mongodb://${dbAuth}@${node[5]}:27017/  \
      mongodb://${dbAuth}@${node[6]}:27017/  \
   )

num=${#cs[@]}

query1="db.adminCommand({setParameter: 1, ldapQueryUser: \"${bindUser}\"         });"
query2="db.adminCommand({setParameter: 1, ldapQueryPassword: \"${bindPassword}\" });"
query3='db.adminCommand({getParameter: 1, ldapQueryUser: ""                      });'
query4='db.adminCommand({getParameter: 1, ldapQueryPassword: ""                  });'

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
