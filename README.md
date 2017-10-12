## Synopsis
This tools checks the ACLs of AWS buckets to see if any permissions have been assigned that do not match policy.

## Usage
```
chmod +x audit.s3.sh [aws credential profile name]
./audits3.sh

Number of Buckets: 9
  1/9   : andy-perm-test                                                   : FAIL 
  2/9   : andy-perm-test-2                                                 : FAIL 
  3/9   : andywirv-cloudtrail                                              : PASS 
  4/9   : bt-mp3                                                           : PASS 
  5/9   : s3-build-cache-example                                           : PASS 
  6/9   : tfb8sdjaumo8y4n3akmg                                             : PASS 
  7/9   : vennart-com-test                                                 : PASS 
  8/9   : wordpress-account                                                : PASS 

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

s3:GetBucketAcl
s3:GetBucketLocation
s3:GetBucketPolicy
s3:ListAllMyBuckets

A full policy example can be found in `./aws_iam/policy.json`
