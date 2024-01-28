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

printf "Updating policy for projectName: $projectName, id: $projectId\n"
set_policy.bash ${reset} -p ${projectId}

exit 0
