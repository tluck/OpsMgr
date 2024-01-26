#!/bin/bash

while getopts 'p:h' opt
do
  case "$opt" in
    p) projectName="$OPTARG";;
    ?|h)
      echo "Usage: $(basename $0) -p projectName [-h]"
      exit 1
      ;;
  esac
done

projectName=${projectName:-myProject1}

output=$( curl $curlOpts --silent --user "${publicKey}:${privateKey}" --digest \
 --header 'Accept: application/json' \
 --header 'Content-Type: application/json' \
 --request GET "${opsMgrUrl}/api/public/v1.0/groups/byName/${projectName}/?pretty=true" )

errorCode=$( printf "%s" "$output" | jq .errorCode )

if [[ "${errorCode}" == "null" ]]
then
    #printf "%s\n" "${output}"
    projectId=( $( printf "%s" "$output" | jq '.id' ))
    eval out=${projectId}
    printf "%s\n" "${out}"
else
    printf "%s\n" "none"
fi
exit 0
