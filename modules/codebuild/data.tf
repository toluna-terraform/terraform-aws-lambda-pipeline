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
      "ssm:*",
      "s3:*",
      "logs:*",
      "lambda:*",
      "ec2:*",
      "iam:*",
      "codedeploy:*",
      "cloudformation:*",
      "apigateway:*"
        ]
    resources = ["*"]
  }
}
