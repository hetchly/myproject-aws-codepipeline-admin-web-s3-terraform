# My Project Consumer Web CodePipeline

## Step 1: Setup CI/CD for Front End

### Step 1.1: Create an S3 Bucket for Pipeline Artifacts
```
$ aws s3 mb s3://jrdalino-myproject-consumer-web-artifacts
```

### Step 1.2: Create Codepipeline Role using CloudFormation
```
$ cd ~/environment/myproject-consumer-web
$ mkdir aws-cli
$ vi ~/environment/myproject-consumer-web/aws-cfn/myproject-consumer-web-codepipeline-service-role-stack.yml
```
```
---
AWSTemplateFormatVersion: '2010-09-09'
Description: This stack deploys the IAM Role for CodePipeline
Resources:
  MyProjectConsumerWebCodePipelineServiceRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: MyProjectConsumerWebCodePipelineServiceRole
      AssumeRolePolicyDocument:
        Statement:
        - Effect: Allow
          Principal:
            Service:
            - codepipeline.amazonaws.com
          Action:
          - sts:AssumeRole
      Path: "/"
      Policies:
      - PolicyName: MyProjectConsumerWebCodePipelineServicePolicy
        PolicyDocument:
          Statement:
          - Action:
            - codecommit:GetBranch
            - codecommit:GetCommit
            - codecommit:UploadArchive
            - codecommit:GetUploadArchiveStatus
            - codecommit:CancelUploadArchive
            Resource: "*"
            Effect: Allow
          - Action:
            - s3:GetObject
            - s3:GetObjectVersion
            - s3:GetBucketVersioning
            Resource: "*"
            Effect: Allow
          - Action:
            - s3:PutObject
            Resource:
            - arn:aws:s3:::*
            Effect: Allow
          - Action:
            - elasticloadbalancing:*
            - autoscaling:*
            - cloudwatch:*
            - ecs:*
            - codebuild:*
            - iam:PassRole
            Resource: "*"
            Effect: Allow
          Version: "2012-10-17"
Outputs:
  CodePipelineRole:
    Description: REPLACE_ME_CODEPIPELINE_ROLE_ARN
    Value: !GetAtt 'MyProjectConsumerWebCodePipelineServiceRole.Arn'
    Export:
      Name: !Join [ ':', [ !Ref 'AWS::StackName', 'MyProjectConsumerWebCodePipelineServiceRole' ] ]
```

## Step 1.3: Create the Stack
```
$ aws cloudformation create-stack \
--stack-name MyProjectConsumerWebCodePipelineServiceRoleStack \
--capabilities CAPABILITY_NAMED_IAM \
--template-body file://~/environment/myproject-consumer-web/aws-cfn/myproject-consumer-web-codepipeline-service-role-stack.yml
```

### Step 1.4: Create S3 Bucket Policy File
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

### Step 1.5: Grant S3 Bucket access to your CI/CD Pipeline
```
$ aws s3api put-bucket-policy \
--bucket jrdalino-myproject-consumer-web-artifacts \
--policy file://~/environment/myproject-consumer-web/aws-cli/artifacts-bucket-policy.json
```

### Step 1.6: Create CodePipeline Input File
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

### Step 1.7: Create a pipeline in CodePipeline
```
$ aws codepipeline create-pipeline \
--cli-input-json file://~/environment/myproject-consumer-web/aws-cli/code-pipeline.json
```

### Step 1.8: Make a small code change, Push and Validate changes

### (Optional) Clean up
```
$ aws codepipeline delete-pipeline --name myproject-consumer-web-codepipeline
$ rm ~/environment/myproject-consumer-web/aws-cli/code-pipeline.json
$ aws s3api delete-bucket-policy --bucket jrdalino-myproject-consumer-web-artifacts
$ rm ~/environment/myproject-consumer-web/aws-cli/artifacts-bucket-policy.json
$ aws s3 rm s3://jrdalino-myproject-consumer-web-artifacts --recursive
$ aws s3 rb s3://jrdalino-myproject-consumer-web-artifacts --force
```
