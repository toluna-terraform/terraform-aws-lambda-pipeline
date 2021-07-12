data "aws_s3_bucket" "codepipeline_bucket" {
  bucket = aws_s3_bucket.codepipeline_bucket.bucket
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
}