# My Project Consumer Web CodePipeline

## Step 1: Setup CI/CD for Front End

### Step 1.1: Create an S3 Bucket for Pipeline Artifacts
```
$ aws s3 mb s3://jrdalino-myproject-consumer-web-artifacts
```

### Step 1.2: Check Codepipeline Roles exists

### Step 1.3: Create S3 Bucket Policy File
```
$ cd ~/environment/myproject-consumer-web
$ mkdir aws-cli
$ vi ~/environment/myproject-consumer-web/aws-cli/artifacts-bucket-policy.json
```

```
{
    "Statement": [
      {
        "Sid": "WhitelistedGet",
        "Effect": "Allow",
        "Principal": {
          "AWS": [
            "arn:aws:iam::707538076348:role/myproject-consumer-web-codepipeline-role"
          ]
        },
        "Action": [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning"
        ],
        "Resource": [
          "arn:aws:s3:::jrdalino-myproject-consumer-web-artifacts/*",
          "arn:aws:s3:::jrdalino-myproject-consumer-web-artifacts"
        ]
      },
      {
        "Sid": "WhitelistedPut",
        "Effect": "Allow",
        "Principal": {
          "AWS": [
            "arn:aws:iam::707538076348:role/myproject-consumer-web-codepipeline-role"
          ]
        },
        "Action": "s3:PutObject",
        "Resource": [
          "arn:aws:s3:::jrdalino-myproject-consumer-web-artifacts/*",
          "arn:aws:s3:::jrdalino-myproject-consumer-web-artifacts"
        ]
      }
    ]
}
```

### Step 1.4: Grant S3 Bucket access to your CI/CD Pipeline
```
$ aws s3api put-bucket-policy \
--bucket jrdalino-myproject-consumer-web-artifacts \
--policy file://~/environment/myproject-consumer-web/aws-cli/artifacts-bucket-policy.json
```

### Step 1.5: Create CodePipeline Input File
```
$ vi ~/environment/myproject-consumer-web/aws-cli/code-pipeline.json
```

```
{
  "pipeline": {
      "name": "myproject-consumer-web-codepipeline",
      "roleArn": "arn:aws:iam::707538076348:role/myproject-consumer-web-codepipeline-role",
      "stages": [
        {
          "name": "Source",
          "actions": [
            {
              "inputArtifacts": [
    
              ],
              "name": "Source",
              "actionTypeId": {
                "category": "Source",
                "owner": "AWS",
                "version": "1",
                "provider": "CodeCommit"
              },
              "outputArtifacts": [
                {
                  "name": "myproject-consumer-web-source-artifact"
                }
              ],
              "configuration": {
                "BranchName": "master",
                "RepositoryName": "myproject-consumer-web"
              },
              "runOrder": 1
            }
          ]
        },
        {
          "name": "Deploy",
          "actions": [
            {
              "name": "Deploy",
              "actionTypeId": {
                "category": "Deploy",
                "owner": "AWS",
                "version": "1",
                "provider": "S3"
              },
              "inputArtifacts": [
                {
                  "name": "myproject-consumer-web-source-artifact"
                }
              ],
              "configuration": {
                  "Extract": "true", 
                  "BucketName": "jrdalino-myproject-consumer-web"
              }
            }
          ]
        }
      ],
      "artifactStore": {
        "type": "S3",
        "location": "jrdalino-myproject-consumer-web-artifacts"
      }
  }
}
```

### Step 1.6: Create a pipeline in CodePipeline
```
$ aws codepipeline create-pipeline \
--cli-input-json file://~/environment/myproject-consumer-web/aws-cli/code-pipeline.json
```

### Step 1.7: Make a small code change, Push and Validate changes

### (Optional) Clean up
```
$ aws codepipeline delete-pipeline --name myproject-consumer-web-codepipeline
$ rm ~/environment/myproject-consumer-web/aws-cli/code-pipeline.json
$ aws s3api delete-bucket-policy --bucket jrdalino-myproject-consumer-web-artifacts
$ rm ~/environment/myproject-consumer-web/aws-cli/artifacts-bucket-policy.json
$ aws s3 rm s3://jrdalino-myproject-consumer-web-artifacts --recursive
$ aws s3 rb s3://jrdalino-myproject-consumer-web-artifacts --force
```
