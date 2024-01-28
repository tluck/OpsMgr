#!/bin/bash -x

while getopts 'n:p:u:w:h' opt
do
  case "$opt" in
    n) name="$OPTARG";;
    p) pn="$OPTARG";;
    u) bu="$OPTARG";;
    w) bp="$OPTARG";;
    ?|h)
      echo "Usage: $(basename $0) -p projectId -u bindUser -p bindPassword [-h]"
      exit 1
      ;;
  esac
done

# OM and API Key
export publicKey="xxxxxxx"
export privateKey="xxxxxxxxxxxxxxxxxxxxxxxxxxx"
export opsMgrUrl="https://opsmanager.mdb.com:8443"
export dbAuth="dbAdmin:Mongodb1"

# variables 
export bindUser=${bu:-"cn=admin,dc=example,dc=org"}
export bindPassword=${bp:-"adminpassword"}
export projectName=${pn:-"myproject1"}
export clusterName=${name:-"myproject1-myreplicaset"}

export projectId=$(get_projectId.bash -p ${projectName})
rm ${projectId}*json
get_automation_hostnames.bash -p ${projectId} 

# not sure we need step 1
#1_clear_or_revert_policy.bash -p ${projectId}
2_unmanage.bash -p ${projectId} 
3_update_config_file.bash -n ${clusterName}
4_update_params.bash -n ${clusterName}
