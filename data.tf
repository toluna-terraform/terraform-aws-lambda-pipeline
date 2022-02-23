data "aws_s3_bucket" "codepipeline_bucket" {
  bucket = local.artifacts_bucket_name
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
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision",
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "s3:PutObjectAcl",
      "s3:PutObject",
      "s3:GetObjectVersion",
      "s3:GetObject",
      "s3:GetBucketVersioning"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup"
    ]
    resources = ["*"]
  }
}

data "aws_ssm_parameter" "ado_password" {
  name = "/app/ado_password"
}

data "aws_ssm_parameter" "ado_user" {
  name = "/app/ado_user"
}