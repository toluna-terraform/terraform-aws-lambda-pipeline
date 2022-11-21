data "aws_s3_bucket" "codepipeline_bucket" {
  bucket = local.artifacts_bucket_name
}

data "aws_ssm_parameter" "ado_password" {
  name = "/app/ado_password"
}

data "aws_ssm_parameter" "ado_user" {
  name = "/app/ado_user"
}