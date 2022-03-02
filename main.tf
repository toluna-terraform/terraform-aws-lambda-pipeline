locals {
  repository_name = split("/",var.source_repository)[1]
  artifacts_bucket_name = "s3-codepipeline-${local.repository_name}-${var.env_type}"
}

module "code-pipeline" {
  source  = "./modules/codepipeline"
  env_name                 = var.env_name
  source_repository        = var.source_repository
  s3_bucket                = local.artifacts_bucket_name
  code_build_projects      = [module.build-code-build.attributes.name,module.deploy-code-build.attributes.name]
  code_deploy_applications = []
  trigger_branch           = var.trigger_branch
  trigger_events           = ["push", "merge"]
}

module "build-code-build" {
  source  = "./modules/codebuild"
  codebuild_name                        = "sam-build"
  env_name                              = var.env_name
  s3_bucket                             = local.artifacts_bucket_name
  privileged_mode                       = true
  environment_variables_parameter_store = {}
  environment_variables                 = merge(var.environment_variables, { APPSPEC = "" }) //TODO: try to replace with file
  buildspec_file                        = templatefile("${path.module}/templates/buildspec-build.yml.tpl",{APP_NAME = var.app_name, ENV_TYPE = var.env_type, ENV_NAME = var.env_name, PIPELINE_TYPE = var.pipeline_type, RUN_TESTS = var.run_integration_tests, RUNTIME_TYPE = var.runtime_type,RUNTIME_VERSION = var.runtime_version,TEMPLATE_FILE_PATH = var.template_file_path,S3_BUCKET = local.artifacts_bucket_name,ADO_USER = data.aws_ssm_parameter.ado_user.value, ADO_PASSWORD = data.aws_ssm_parameter.ado_password.value, SLN_PATH = var.solution_file_path})
}

module "deploy-code-build" {
  source  = "./modules/codebuild"
  codebuild_name                        = "sam-deploy"
  env_name                              = var.env_name
  s3_bucket                             = local.artifacts_bucket_name
  privileged_mode                       = true
  environment_variables_parameter_store = {}
  environment_variables                 = merge(var.environment_variables, { APPSPEC = "" }) //TODO: try to replace with file
  buildspec_file                        = templatefile("${path.module}/templates/buildspec-deploy.yml.tpl",{APP_NAME = var.app_name, FROM_ENV = var.from_env,  ENV_TYPE = var.env_type, ENV_NAME = var.env_name, PIPELINE_TYPE = var.pipeline_type, RUN_TESTS = var.run_integration_tests, RUNTIME_TYPE = var.runtime_type,RUNTIME_VERSION = var.runtime_version,TEMPLATE_FILE_PATH = var.template_file_path,S3_BUCKET = local.artifacts_bucket_name, CORALOGIX_SUBSCRIPTION=var.enable_coralogix_subscription ? templatefile("${path.module}/templates/subscribe_log_group.sh.tpl",{ENV_NAME = var.env_name,APP_NAME = var.app_name}) : "" })
}

resource "null_resource" "samconfig_generation" {
  triggers = {
    policy_sha1 = "${sha1(file("samconfig.toml.j2"))}"
  }

  provisioner "local-exec" {
    command = "jinja2 samconfig.toml.j2 -D env=${var.env_name} -D env_type=${var.env_type} -o ../../${var.template_file_path}/samconfig.toml"
  }
}

resource "null_resource" "sam_delete" {
  triggers = {
    stackname = "${var.app_name}-${var.env_name}"
    aws_profile = "${var.aws_profile}"
  }

  provisioner "local-exec" {
    when       = destroy
    on_failure = fail
    command    = "aws cloudformation delete-stack --stack-name ${self.triggers.stackname} --profile ${self.triggers.aws_profile}"
  }
}