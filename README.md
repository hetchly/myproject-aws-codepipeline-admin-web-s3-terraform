# Terraform module to provision a CI/CD Pipeline using AWS Managed Services (React Web Application)

## This creates the following resources:
- S3 Bucket for Artifacts
- Service Role for CodeBuild
- CodeBuild Project
- Service Role for CodePipeline
- CodePipeline Pipeline

## CI/CD Pipline Usage
1. Developers commit code to an Github repository and create pull requests to review proposed changes to the production code. When the pull request is merged into the master branch in the Github repository, AWS CodePipeline automatically detects the changes to the branch and starts processing the code changes through the pipeline.
2. AWS CodeBuild runs yarn buil
4. AWS CodePipeline deploys the build file into the destination S3 Bucket

## Prerequisites
- Provision an S3 bucket to store Terraform State and DynamoDB for state-lock
using https://github.com/jrdalino/aws-tfstate-backend-terraform
- CloudFront Distribution w/ S3 Bucket as origin

## Usage
- Replace variables in terraform.tfvars
- Replace variables in state_config.tf
- Initialize, Review Plan and Apply
```
$ terraform init
$ terraform plan
$ terraform apply
```

## (Optional) Cleanup
```
$ terraform destroy
```

## Inputs
| Name | Description |
|------|-------------|

## Outputs
| Name | Description |
|------|-------------|