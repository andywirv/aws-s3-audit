#!/bin/bash

# This script uses the AWS cli tools (and the credentials you have configured in ~/.aws/credentials)
# specify the profile name to use as first argument. Optionally leave blank to use default profile
set -eo pipefail
trap "exit" INT TERM
trap "printf 'Exiting...\n' 1>&2 && kill 0" EXIT

main () {
    # Output constants used in formatting
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    NC='\033[0m' # No Color    

    printf "[" > failed.json

    PROFILE=${1:-default}
    if [ -z "$1" ]; then
        printf "\nno profile specified so using 'default'\n"
    fi
    printf "AWS Profile: $PROFILE\n"

    # Get list of S3 buckets from AWS
    buckets=$(aws --profile $PROFILE s3api list-buckets | jq -r '.Buckets[] .Name');
    bucketArray=($buckets);
    numBuckets=${#bucketArray[@]}
    numFailures=0
    printf 'Number of Buckets: %s\n' "$numBuckets"

    #  Loop through buckets checking for permissions that allow eiher:
    #  1. Any AWS Authenticated user http://acs.amazonaws.com/groups/global/AuthenticatedUsers. This is bad
    #  2. Everyone  "http://acs.amazonaws.com/groups/global/AllUsers. This is even worse unless is intended to be public.
    for ((i=0; i<${#bucketArray[@]}; ++i)); do
        bucketregion=$(jq --raw-output '.LocationConstraint' \
                    <<< $(aws s3api  --profile $PROFILE get-bucket-location --bucket ${bucketArray[$i]}))
        if [ "$bucketregion" != "null" ]; then
                # For some reason eu-west-1 buckets may also be labelled as EU. If that happens relabel as eu-west-1
                if [ $bucketregion == "EU" ]; then
                    bucketregion="eu-west-1"
                fi
                acl=$(aws --region $bucketregion --profile $PROFILE s3api  get-bucket-acl --bucket ${bucketArray[$i]});
            else
                acl=$(aws --profile $PROFILE s3api  get-bucket-acl --bucket ${bucketArray[$i]});
        fi
        bucketname=${bucketArray[$i]}
        bucketPermission=$(jq --arg BCKT_NAME ${bucketname} \
                        '. | select( .Grants[] .Grantee .URI == "http://acs.amazonaws.com/groups/global/AuthenticatedUsers" or .Grants[] .Grantee .URI == "http://acs.amazonaws.com/groups/global/AllUsers") | .Bucket=$BCKT_NAME' \
                        <<< "$acl")

        if [ -n "$bucketPermission" ]; then
                numFailures=$((numFailures+1))
                result="FAIL"
                colour=$RED

                # This is just to separate objects in the JSON output
                if [ $numFailures -ne 1 ]; then
                    comma=","
                fi
                printf "%s %s" "$comma" "$(jq --raw-output --arg bucketname $bucketname '.bucketname=$bucketname' \
                        <<< $acl)" >> failed.json
        else
            result='PASS'
            colour=$GREEN
        fi

        printf "%3s/%-3s : %-64s :$colour %s $NC\n" "$(($i + 1))" "$numBuckets" "$bucketname" "$result";
    done;
    printf "]" >> failed.json
    printf "$GREEN Passed:%s $RED Failed:%s $NC\n" "$((numBuckets-numFailures))" "$numFailures"
}
main "$@"