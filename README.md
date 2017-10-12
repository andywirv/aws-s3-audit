## Synopsis
This tools checks the ACLs of AWS buckets to see if any permissions have been assigned that do not match policy.

## Usage
```
chmod +x audit.s3.sh 
./audits3.sh [aws credential profile name]

Number of Buckets: 3
  1/3   : bucket-1                                              : FAIL 
  2/3   : bucket-2                                              : FAIL 
  3/3   : bucket-3                                              : PASS 
```

## Installation

You need:
* AWS cli tools http://docs.aws.amazon.com/cli/latest/userguide/installing.html 
* jq cli https://stedolan.github.io/jq/

Config:
Add at least one profile to ~/.aws/credentials.
```
cat ~/.aws/credentials 
[default]
aws_access_key_id = [your access key id]
aws_secret_access_key = [your secret key]
```

Access Required for IAM user:
```
s3:GetBucketAcl
s3:GetBucketLocation
s3:GetBucketPolicy
s3:ListAllMyBuckets
```
A full policy example can be found in `./aws_iam/policy.json`
