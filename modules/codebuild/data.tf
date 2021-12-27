data "aws_s3_bucket" "codepipeline_bucket" {
  bucket = var.s3_bucket
}

data "aws_iam_policy_document" "codebuild_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
        }
    }
}

data "aws_iam_policy_document" "codebuild_role_policy" {
  statement {
    actions   = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:PutSubscriptionFilter",
            "logs:DescribeLogGroups",
            "ssm:*",
            "cloudformation:*",
            "s3:*",
            "apigateway:*",
            "lambda:*"
        ]
    resources = ["*"]
  }
}
