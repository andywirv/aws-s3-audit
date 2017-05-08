#!/bin/bash

PROFILE=${1:-default}

#Output constants
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Create Output file
filename=$(date +%Y%m%d_%H%M)-report.json
echo '{"permission_issues": []}' > ./$filename

# Get list of S3 buckets from AWS
buckets=$(aws --profile $PROFILE s3api list-buckets | jq -r '.Buckets[] .Name');
bucketArray=($buckets);
echo 'Number of Buckets:' ${#bucketArray[@]}

#Loop through buckets checking for permissions that allow allow all authenticated users to access (any permisisons)
for ((i=0; i<${#bucketArray[@]}; ++i));
    do  
       acl=$(aws --profile $PROFILE s3api  get-bucket-acl --bucket ${bucketArray[$i]});
       bucketname=${bucketArray[$i]}
       bucketinstance=$(jq --arg BCKT_NAME ${bucketname} '. | select( .Grants[] .Grantee .URI == "http://acs.amazonaws.com/groups/global/AuthenticatedUsers") | .Bucket=$BCKT_NAME' <<< "$acl")
    if [ -n "$bucketinstance" ]
        then
            result="FAIL"
            colour=$RED
            cat $filename | jq  --argjson BCK_INST "${bucketinstance}" '.permission_issues |= . + [$BCK_INST]'  | tee  $filename >>/dev/null
        else
            result='PASS'
            colour=$GREEN            
    fi
    printf "%-64s :$colour %s $NC\n" "$bucketname" "$result";
done;