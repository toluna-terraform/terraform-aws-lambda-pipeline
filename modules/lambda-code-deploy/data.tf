data "aws_s3_bucket" "codepipeline_bucket" {
  bucket = var.s3_bucket
}

data "aws_iam_policy_document" "codedeploy_role_policy" {
  statement {
    actions   = [
            "lambda:*",
            "cloudwatch:DescribeAlarms"
        ]
    # TODO: replace with lambda arn
    resources = ["*"]
  }
  statement {
    actions = [
      "codedeploy:*"
      # "codedeploy:CreateDeployment",
      # "codedeploy:GetApplicationRevision",
      # "codedeploy:GetDeployment",
      # "codedeploy:GetDeploymentConfig",
      # "codedeploy:RegisterApplicationRevision"
    ]
    resources = ["*"]
  }
  statement {
    actions   = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObjectAcl",
          "s3:PutObject"
        ]
    resources = [
          "${data.aws_s3_bucket.codepipeline_bucket.arn}",
          "${data.aws_s3_bucket.codepipeline_bucket.arn}/*"
        ]
  }
}