#!/bin/bash

# This script uses the AWS cli tools (and the credentials you have configured in ~/.aws/credentials)
# specify the profile to use as first argument. Optionally leave blank to use default profile
PROFILE=${1:-default}

#Output constants
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color


# Create Output file
#filename=$(date +%Y%m%d_%H%M)-report.json
#echo '{"permission_issues": []}' > ./$filename

# Get list of S3 buckets from AWS
buckets=$(aws --profile $PROFILE s3api list-buckets | jq -r '.Buckets[] .Name');
bucketArray=($buckets);
numBuckets=${#bucketArray[@]}
printf 'Number of Buckets: %s\n' "$numBuckets"



#Loop through buckets checking for permissions that allow allow all authenticated users to access (any permisisons)
for ((i=0; i<${#bucketArray[@]}; ++i));
    do
        bucketregion=$(jq --raw-output '.LocationConstraint' <<< $(aws s3api  --profile $PROFILE get-bucket-location --bucket ${bucketArray[$i]}))
        if [ "$bucketregion" != "null" ]
            then
                acl=$(aws --region $bucketregion --profile $PROFILE s3api  get-bucket-acl --bucket ${bucketArray[$i]});
            else
                acl=$(aws --profile $PROFILE s3api  get-bucket-acl --bucket ${bucketArray[$i]});
        fi
        bucketname=${bucketArray[$i]}
        bucketinstance=$(jq --arg BCKT_NAME ${bucketname} '. | select( .Grants[] .Grantee .URI == "http://acs.amazonaws.com/groups/global/AuthenticatedUsers") | .Bucket=$BCKT_NAME' <<< "$acl")

        if [ -n "$bucketinstance" ]
            then
                result="FAIL"
                colour=$RED
                #cat $filename | jq  --argjson BCK_INST "${bucketinstance}" '.permission_issues |= . + [$BCK_INST]'  | tee  $filename >>/dev/null
        else
            result='PASS'
            colour=$GREEN
        fi
        
        printf "%3s/%-3s : %-64s :$colour %s $NC\n" "$(($i + 1))" "$numBuckets" "$bucketname" "$result";
done;