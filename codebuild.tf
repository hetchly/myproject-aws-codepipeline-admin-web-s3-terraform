# CodeBuild Role
resource "aws_iam_role" "codebuild_service_role" {
  name = var.codebuild_service_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_service_role_policy" {
  name = var.codebuild_service_role_policy_name
  role = aws_iam_role.codebuild_service_role.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:ListBucket"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

# CodeBuild Project
resource "aws_codebuild_project" "build_project" {
  name        = var.codebuild_project_name
  description = "The CodeBuild project for ${var.github_repo_name}"

  # Source
  source {
    type     = "GITHUB"
    location = "https://github.com/hetchly/${var.github_repo_name}"
  }

  # Environment
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:4.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = "true"

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.aws_account
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
          
  }
  service_role  = aws_iam_role.codebuild_service_role.arn
  build_timeout = "5" # Adjust this if needed
  
  # Artifacts
  artifacts {
    type = "NO_ARTIFACTS" # Push Docker Image to ECR
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  # Logs
  logs_config {
    cloudwatch_logs {
      group_name = "/aws/codebuild/${var.codebuild_project_name}"
    }
  }
}