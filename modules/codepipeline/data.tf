data "aws_s3_bucket" "codepipeline_bucket" {
  bucket = var.s3_bucket
}

data "aws_ssm_parameter" "codepipeline_connection_arn" {
  name = "/infra/codepipeline/connection_arn"
}

data "aws_iam_policy_document" "codepipeline_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = [
        "codepipeline.amazonaws.com", 
        "codebuild.amazonaws.com", 
        "cloudformation.amazonaws.com", 
        "iam.amazonaws.com",
        "ssm.amazonaws.com",
        "route53.amazonaws.com"
        ]
    }
  }
}

data "aws_iam_policy_document" "codepipeline_role_policy" {
  statement {
    actions = [
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
  statement {
    actions   = ["codestar-connections:UseConnection"]
    resources = ["*"]
  }
  statement {
    actions = [
      "iam:*",
      "logs:*",
      "apigateway:*",
      "cloudformation:*",
      "s3:*",
      "ec2:*",
      "ssm:*",
      "lambda:*",
      "codedeploy:*",
      "codebuild:*",
      "serverlessrepo:*",
      "sqs:*",
      "route53:*"
    ]
    resources = ["*"]
  }
}
