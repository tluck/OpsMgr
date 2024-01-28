#!/bin/bash

while getopts 'p:rh' opt
do
  case "$opt" in
    p) projectId="$OPTARG";;
    r) reset=true;;
    ?|h)
      echo "Usage: $(basename $0) -p projectName [-h]"
      exit 1
      ;;
  esac
done

#projectName=${projectName:-myproject1}
#projectId=$(get_projectId.bash -p ${projectName})

output=$( curl $curlOpts --silent --user "${publicKey}:${privateKey}" --digest \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --request GET "${opsMgrExtUrl1}/api/public/v1.0/groups/${projectId}/automationConfig?pretty=true" )

errorCode=$( printf "%s" "$output" | jq .errorCode )

if [[ "${errorCode}" == "null" ]]
then
    printf "Hostnames\n"
    printf "%s\n" "$output" | jq .monitoringVersions[].hostname
    printf "%s\n" "$output" | jq .monitoringVersions[].hostname > ${projectId}_hostnames
    printf "The automation config is in ${projectId}_automation.json\n"
    printf "%s" "$output"  > ${projectId}_automation.json
    exit 0
else
    printf "%s\n" "none"
    exit 1
fi
