# General
variable "aws_region" {
  type        = "string"
  description = "Used AWS Region."    
}

variable "aws_account" {
  type        = "string"
  description = "Used AWS Account."    
}

# Github Repository
variable "github_repo_name" {
  type        = "string"
  description = "Github Repository name."
}

variable "github_oauth_token" {
  type        = "string"
  description = "Github OAuth token."
}

# S3 Bucket for Artifacts
variable "s3_bucket_artifacts_name" {
  type        = "string"
  description = "S3 Bucket for Artifacts name."    
}

# CodeBuild Role
variable "codebuild_service_role_name" {
  type        = "string"
  description = "CodeBuild Service Role name."  
}

variable "codebuild_service_role_policy_name" {
  type        = "string"
  description = "CodeBuild Service Role Policy name."    
}

variable "codebuild_project_name" {
  type        = "string"
  description = "Codebuild Project name."    
}

# CodePipeline Pipeline
variable "codepipeline_service_role_name" {
  type        = "string"
  description = "CodePipeline Service Role name."    
}

variable "codepipeline_service_role_policy_name" {
  type        = "string"
  description = "CodePipeline Service Role Policy name."    
}

variable "codepipeline_pipeline_name" {
  type        = "string"
  description = "Codepipeline pipeline name."    
}