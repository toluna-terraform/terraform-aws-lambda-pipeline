locals {
  repository_name = split("/",var.source_repository)[1]
  artifacts_bucket_name = "s3-codepipeline-${local.repository_name}-${var.env_name}"
}

module "code-pipeline" {
  source  = "./modules/codepipeline"
  env_name                 = var.env_name
  source_repository        = var.source_repository
  s3_bucket                = aws_s3_bucket.codepipeline_bucket.bucket
  code_build_projects      = [module.build-code-build.attributes.name,module.deploy-code-build.attributes.name]
  code_deploy_applications = []
  trigger_branch           = var.trigger_branch
  trigger_events           = ["push", "merge"]
  depends_on = [
    aws_s3_bucket.codepipeline_bucket,
  ]
}

module "build-code-build" {
  source  = "./modules/codebuild"
  codebuild_name                        = "sam-build"
  env_name                              = var.env_name
  s3_bucket                             = aws_s3_bucket.codepipeline_bucket.bucket
  privileged_mode                       = true
  environment_variables_parameter_store = {}
  environment_variables                 = merge(var.environment_variables, { APPSPEC = "" }) //TODO: try to replace with file
  buildspec_file                        = templatefile("buildspec-build.yml.tpl",{ RUNTIME_TYPE = var.runtime_type,RUNTIME_VERSION = var.runtime_version,TEMPLATE_FILE_PATH = var.template_file_path,S3_BUCKET = aws_s3_bucket.codepipeline_bucket.bucket,ADO_USER = data.aws_ssm_parameter.ado_user.value, ADO_PASSWORD = data.aws_ssm_parameter.ado_password.value, SLN_PATH = var.solution_file_path})
  depends_on = [
    aws_s3_bucket.codepipeline_bucket,
  ]
}

module "deploy-code-build" {
  source  = "./modules/codebuild"
  codebuild_name                        = "sam-deploy"
  env_name                              = var.env_name
  s3_bucket                             = aws_s3_bucket.codepipeline_bucket.bucket
  privileged_mode                       = true
  environment_variables_parameter_store = {}
  environment_variables                 = merge(var.environment_variables, { APPSPEC = "" }) //TODO: try to replace with file
  buildspec_file                        = templatefile("buildspec-deploy.yml.tpl",{ ENV_NAME = var.env_name, RUNTIME_TYPE = var.runtime_type,RUNTIME_VERSION = var.runtime_version,TEMPLATE_FILE_PATH = var.template_file_path,S3_BUCKET = aws_s3_bucket.codepipeline_bucket.bucket})
  depends_on = [
    aws_s3_bucket.codepipeline_bucket,
  ]
}


resource "aws_s3_bucket" "codepipeline_bucket" {
 bucket = local.artifacts_bucket_name
 force_destroy = true
 acl = "private"
 tags = tomap({
   UseWithCodeDeploy = true
   created_by        = "terraform"
 })
}


resource "null_resource" "samconfig_generation" {
  triggers = {
    policy_sha1 = "${sha1(file("samconfig.toml.j2"))}"
  }

  provisioner "local-exec" {
    command = "jinja2 samconfig.toml.j2 -D env=${var.env_name} -o ../../${var.template_file_path}/samconfig.toml"
  }
}