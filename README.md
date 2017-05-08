## Synopsis
This tools checks the ACLs of AWS buckets to see if any permissions have been assigned that do not match policy.

## Usage
```
chmod +x audit.s3.sh
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
* AWS cli tools      http://docs.aws.amazon.com/cli/latest/userguide/installing.html * jq cli https://stedolan.github.io/jq/

