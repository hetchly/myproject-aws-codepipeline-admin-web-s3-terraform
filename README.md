# Frontend CICD CodeCommit & CodePipeline

## Step 7: Setup CI/CD for Front End

### Step 7.1: Create an S3 Bucket for Pipeline Artifacts
```
$ aws s3 mb s3://jrdalino-calculator-frontend-artifacts
```

### Step 7.2: Check Codepipeline Roles exists

### Step 7.3: Create S3 Bucket Policy File
```
$ cd ~/environment/calculator-frontend
$ mkdir aws-cli
$ vi ~/environment/calculator-frontend/aws-cli/artifacts-bucket-policy.json
```

```
{
    "Statement": [
      {
        "Sid": "WhitelistedGet",
        "Effect": "Allow",
        "Principal": {
          "AWS": [
            "arn:aws:iam::707538076348:role/CalculatorServiceCodePipelineServiceRole"
          ]
        },
        "Action": [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning"
        ],
        "Resource": [
          "arn:aws:s3:::jrdalino-calculator-frontend-artifacts/*",
          "arn:aws:s3:::jrdalino-calculator-frontend-artifacts"
        ]
      },
      {
        "Sid": "WhitelistedPut",
        "Effect": "Allow",
        "Principal": {
          "AWS": [
            "arn:aws:iam::707538076348:role/CalculatorServiceCodePipelineServiceRole"
          ]
        },
        "Action": "s3:PutObject",
        "Resource": [
          "arn:aws:s3:::jrdalino-calculator-frontend-artifacts/*",
          "arn:aws:s3:::jrdalino-calculator-frontend-artifacts"
        ]
      }
    ]
}
```

### Step 7.4: Grant S3 Bucket access to your CI/CD Pipeline
```
$ aws s3api put-bucket-policy \
--bucket jrdalino-calculator-frontend-artifacts \
--policy file://~/environment/calculator-frontend/aws-cli/artifacts-bucket-policy.json
```

### Step 7.5: Create CodePipeline Input File
```
$ vi ~/environment/calculator-frontend/aws-cli/code-pipeline.json
```

```
{
  "pipeline": {
      "name": "CalculatorFrontendServiceCICDPipeline",
      "roleArn": "arn:aws:iam::707538076348:role/CalculatorServiceCodePipelineServiceRole",
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
                  "name": "CalculatorFrontendService-SourceArtifact"
                }
              ],
              "configuration": {
                "BranchName": "master",
                "RepositoryName": "calculator-frontend"
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
                  "name": "CalculatorFrontendService-SourceArtifact"
                }
              ],
              "configuration": {
                  "Extract": "true", 
                  "BucketName": "jrdalino-calculator-frontend"
              }
            }
          ]
        }
      ],
      "artifactStore": {
        "type": "S3",
        "location": "jrdalino-calculator-frontend-artifacts"
      }
  }
}
```

### Step 7.6: Create a pipeline in CodePipeline
```
$ aws codepipeline create-pipeline \
--cli-input-json file://~/environment/calculator-frontend/aws-cli/code-pipeline.json
```

### Step 7.7: Make a small code change, Push and Validate changes

### (Optional) Clean up
```
$ aws codepipeline delete-pipeline --name CalculatorFrontendServiceCICDPipeline
$ rm ~/environment/calculator-frontend/aws-cli/code-pipeline.json
$ aws s3api delete-bucket-policy --bucket jrdalino-calculator-frontend-artifacts
$ rm ~/environment/calculator-frontend/aws-cli/artifacts-bucket-policy.json
$ aws s3 rm s3://jrdalino-calculator-frontend-artifacts --recursive
$ aws s3 rb s3://jrdalino-calculator-frontend-artifacts --force
```
