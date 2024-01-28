#!/bin/bash

while getopts 'p:rh' opt
do
  case "$opt" in
    p) projectId="$OPTARG";;
    r) reset=true;;
    ?|h)
      echo "Usage: $(basename $0) -p projectId [-h]"
      exit 1
      ;;
  esac
done

output=$( curl $curlOpts --silent --user "${publicKey}:${privateKey}" --digest \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --request GET "${opsMgrExtUrl1}/api/public/v1.0/groups/${projectId}/automationConfig?pretty=true" )

errorCode=$( printf "%s" "$output" | jq '.errorCode' )

if [[ ${reset} != true ]]
then

for item in processes replicaSets clusterWideConfigurations ldap
do
  [[ ! -e ${projectId}_${item}.json ]] && printf "%s" "$output" |jq ".${item}" > ${projectId}_${item}.json
done

fi

#if [[ "${errorCode}" == "null" ]]
#then
  if [[ ${reset} == true ]]
  then
    proc='{"processes":                 '$( cat ${projectId}_processes.json )'}'
    reps='{"replicaSets":               '$( cat ${projectId}_replicaSets.json )'}'
    cwcs='{"clusterWideConfigurations": '$( cat ${projectId}_clusterWideConfigurations.json )'}'
    #jsonData=$( printf "%s" "$output" |jq 'del(.replicaSets,.processes)'\
    printf "%s" "$output" |jq 'del(.replicaSets,.processes,.clusterWideConfigurations)' \
      | jq '. +='"${proc}"' ' \
      | jq '. +='"${reps}"' ' \
      | jq '. +='"${cwcs}"' ' \
      | sed -e 's/QueryPassword\":.*/QueryPassword\": "'${bindPassword}'",/' -e 's/QueryUser\":.*/QueryUser\": "'${bindUser}'",/' \
      > $$.json
  else
    # replace with empty
    jsonData='{"replicaSets": [], "processes": []}'
    printf "%s" "$output" |jq 'del(.replicaSets,.processes,.clusterWideConfigurations,.ldap)' \
      | jq '. +='"${jsonData}"' ' \
      > $$.json
      #| sed -e 's/QueryPassword\":.*/QueryPassword\": "'${bindPassword}'",/' -e 's/QueryUser\":.*/QueryUser\": "'${bindUser}'",/' \
    #jsonData=$( printf "%s" "$output" |jq 'del(.replicaSets,.processes,.mongoDbVersions)'| jq '. +='"${part1}"' '| jq '. +='"${part2}"' ' )
  fi
  curlData=' '"$jsonData"' '

  output=$( curl $curlOpts --silent --user "${publicKey}:${privateKey}" --digest \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --request PUT "${opsMgrExtUrl1}/api/public/v1.0/groups/${projectId}/automationConfig?pretty=true" \
  --data "@$$.json" )
#  --data "${curlData}" )
#fi

errorCode=$( printf "%s" "$output" | jq '.errorCode' )
if [[ "${errorCode}" == "null" ]]
then
    [[ -e $$.json ]] && rm $$.json
    printf "\n%s\n" "New Config"
    printf "%s" "$output" | jq '.replicaSets,.processes' 
    #[[ ${reset} == true ]] && rm ${projectId}_configuration.json
    exit 0
else
    printf "%s\n" "none"
    exit 1
fi
