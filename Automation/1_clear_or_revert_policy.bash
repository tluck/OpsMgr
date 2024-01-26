#!/bin/bash

while getopts 'p:rh' opt
do
  case "$opt" in
    p) projectName="$OPTARG";;
    r) reset='-r';;
    ?|h)
      echo "Usage: $(basename $0) -p projectName [-r] [-h]"
      echo "       -r will restore to previous policy"
      exit 1
      ;;
  esac
done

# variables for OM - Global API key
export publicKey="xxxxxxx"
export privateKey="xxxxxxxxxxxxxxxxxxxxxxxxxxx"
export opsMgrUrl="https://opsmanager.mdb.com:8443"

# get projectId give an projectName
projectName=${projectName:-myproject1}
projectId=$(get_projectId.bash -p ${projectName})

printf "Updating policy for projectName: $projectName, id: $projectId\n"
set_policy.bash ${reset} -p ${projectId}

exit 0
