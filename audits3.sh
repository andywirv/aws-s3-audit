#!/bin/bash

# This script uses the AWS cli tools (and the credentials you have configured in ~/.aws/credentials)
# specify the profile to use as first argument. Optionally leave blank to use default profile


#Output constants used in formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

trap "exit" INT TERM
trap "printf 'Exiting...\n' 1>&2 && kill 0" EXIT
set -e

PROFILE=${1:-default}
if [ -z "$1" ]
    then
        printf "\nno profile specified so using 'default'\n"
fi
printf "AWS Profile: $PROFILE\n"


# Get list of S3 buckets from AWS
buckets=$(aws --profile $PROFILE s3api list-buckets | jq -r '.Buckets[] .Name');
bucketArray=($buckets);
numBuckets=${#bucketArray[@]}
printf 'Number of Buckets: %s\n' "$numBuckets"

#  Loop through buckets checking for permissions that allow eiher:
#  1. Any AWS Authenticated user http://acs.amazonaws.com/groups/global/AuthenticatedUsers. This is bad
#  2. Everyone  "http://acs.amazonaws.com/groups/global/AllUsers. This is even worse unless is intended to be public.
for ((i=0; i<${#bucketArray[@]}; ++i));
    do
        bucketregion=$(jq --raw-output '.LocationConstraint' <<< $(aws s3api  --profile $PROFILE get-bucket-location --bucket ${bucketArray[$i]}))
        if [ "$bucketregion" != "null" ]; then
                if [ $bucketregion == "EU" ]; then
                    bucketregion="eu-west-1"
                fi
                acl=$(aws --region $bucketregion --profile $PROFILE s3api  get-bucket-acl --bucket ${bucketArray[$i]});
            else
                acl=$(aws --profile $PROFILE s3api  get-bucket-acl --bucket ${bucketArray[$i]});
        fi
        bucketname=${bucketArray[$i]}
        bucketinstance=$(jq --arg BCKT_NAME ${bucketname} \
                        '. | select( .Grants[] .Grantee .URI == "http://acs.amazonaws.com/groups/global/AuthenticatedUsers" or .Grants[] .Grantee .URI == "http://acs.amazonaws.com/groups/global/AllUsers") | .Bucket=$BCKT_NAME' \
                        <<< "$acl")
        
        if [ -n "$bucketinstance" ]; then
                result="FAIL"
                colour=$RED
                echo $bucketname >> failed.txt
                echo $acl >> failed.txt
        else
            result='PASS'
            colour=$GREEN
        fi
        
        printf "%3s/%-3s : %-64s :$colour %s $NC\n" "$(($i + 1))" "$numBuckets" "$bucketname" "$result";
done;