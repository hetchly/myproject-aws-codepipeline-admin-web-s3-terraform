# CodePipeline Role
resource "aws_iam_role" "codepipeline_service_role" {
  name = "${var.codepipeline_service_role_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_service_role_policy" {
  name = "${var.codepipeline_service_role_policy_name}"
  role = "${aws_iam_role.codepipeline_service_role.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:UploadArchive",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:CancelUploadArchive"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketVersioning"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "autoscaling:*",
                "cloudwatch:*",
                "codebuild:*",
                "codepipeline:*",
                "codedeploy:*",
                "ecs:*",
                "eks:*",
                "elasticloadbalancing:*",
                "iam:ListRoles",
                "iam:PassRole",
                "lambda:*",
                "sns:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

# CodePipeline Pipeline
resource "aws_codepipeline" "codepipeline" {
  name     = "${var.codepipeline_pipeline_name}"
  role_arn = "${aws_iam_role.codepipeline_service_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.build_artifact_bucket.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner          = "hetchly"
        Repo           = "${var.github_repo_name}"
        Branch         = "master"
        OAuthToken     = "${var.github_oauth_token}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "${aws_codebuild_project.build_project.name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        Extract   = "true"
        BucketName = "jrdalino-myproject-admin-web"
      }
    }
  }
}