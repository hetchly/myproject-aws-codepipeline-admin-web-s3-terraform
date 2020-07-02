# S3 Bucket for Artifacts
resource "aws_s3_bucket" "build_artifact_bucket" {
  bucket        = var.s3_bucket_artifacts_name
  acl           = "private"
  force_destroy = "true"
}

resource "aws_s3_bucket_policy" "build_artifact_bucket" {
  bucket = aws_s3_bucket.build_artifact_bucket.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "MYBUCKETPOLICY",
  "Statement": [
    {
      "Sid": "WhitelistedGet",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${var.aws_account}:role/${var.codebuild_service_role_name}",
          "arn:aws:iam::${var.aws_account}:role/${var.codepipeline_service_role_name}"
        ]
      },
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning"
      ],
      "Resource": [
        "arn:aws:s3:::${var.s3_bucket_artifacts_name}/*",
        "arn:aws:s3:::${var.s3_bucket_artifacts_name}"
      ]
    },
    {
      "Sid": "WhitelistedPut",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${var.aws_account}:role/${var.codebuild_service_role_name}",
          "arn:aws:iam::${var.aws_account}:role/${var.codepipeline_service_role_name}"
        ]
      },
      "Action": "s3:PutObject",
      "Resource": [
        "arn:aws:s3:::${var.s3_bucket_artifacts_name}/*",
        "arn:aws:s3:::${var.s3_bucket_artifacts_name}"
      ]
    }
  ]
}
POLICY
}