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
    actions = [
      "iam:*",
      "apigateway:*",
      "ssm:*",
      "sqs:*",
      "s3:*",
      "logs:*",
      "ssm:*",
      "lambda:*",
      "codedeploy:*",
      "ec2:*",
      "cloudformation:*",
      "acm:*",
      "route53:*",
      "codebuild:*",
      "events:*"
    ]
    resources = ["*"]
  }
}
