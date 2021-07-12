locals {
  repository_name = split("/",var.source_repository)[1]
  artifacts_bucket_name = "s3-codepipeline-${var.env_name}-${local.repository_name}"
  codepipeline_name     = "codepipeline-${var.env_name}-${local.repository_name}"
}

module "code-pipeline" {
  source  = "./modules/lambda-code-pipeline"
  env_name                 = var.env_name
  source_repository        = var.source_repository
  s3_bucket                = aws_s3_bucket.codepipeline_bucket.bucket
  code_build_projects      = [module.code-build.attributes.name]
  code_deploy_applications = [module.lambda-code-deploy.attributes.name]
  trigger_branch           = var.trigger_branch
  trigger_events           = ["push", "merge"]
  depends_on = [
    aws_s3_bucket.codepipeline_bucket,
  ]
}

module "code-build" {
  source  = "toluna-terraform/code-build/aws"
  version = "~>1.0.1"
  #source                                = "../terraform-aws-code-build"
  env_name                              = var.env_name
  s3_bucket                             = aws_s3_bucket.codepipeline_bucket.bucket
  privileged_mode                       = true
  environment_variables_parameter_store = {}
  environment_variables                 = merge(var.environment_variables, { APPSPEC = file("${path.module}/templates/appspec.json.tpl") }) //TODO: try to replace with file
  buildspec_file                        = templatefile("${path.module}/templates/buildspec.yml.tpl",{ RUNTIME_TYPE = var.runtime_type,RUNTIME_VERSION = var.runtime_version,TEMPLATE_FILE_PATH = var.template_file_path,S3_BUCKET = aws_s3_bucket.codepipeline_bucket.bucket})
  depends_on = [
    aws_s3_bucket.codepipeline_bucket,
  ]
}


module "lambda-code-deploy" {
  source  = "./modules/lambda-code-deploy"
  env_name           = var.env_name
  s3_bucket          = aws_s3_bucket.codepipeline_bucket.bucket
  depends_on = [
    aws_s3_bucket.codepipeline_bucket
  ]
}


resource "aws_s3_bucket" "codepipeline_bucket" {
 bucket = local.artifacts_bucket_name
 acl = "private"
 tags = tomap({
   UseWithCodeDeploy = true
   created_by        = "terraform"
 })
}
