data "aws_s3_bucket" "codepipeline_bucket" {
  bucket = var.s3_bucket
}

data "aws_ssm_parameter" "ado_password" {
  name = "/app/ado_password"
}

data "aws_ssm_parameter" "ado_user" {
  name = "/app/ado_user"
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