locals {
  codepipeline_name = "codepipeline-${var.app_name}-${var.env_name}"
}

resource "aws_codepipeline" "codepipeline" {
  name     = local.codepipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = var.s3_bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Download_Merged_Sources"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        S3Bucket             = "${var.s3_bucket}"
        S3ObjectKey          = "${var.env_name}/source_artifacts.zip"
        PollForSourceChanges = true
      }
    }
  }

  stage {
    name = "SAM-Build"
    action {
      name             = "SAM-Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      version          = "1"
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = "codebuild-sam-build-${var.app_name}-${var.env_name}"
      }

    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "SAM-Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      input_artifacts = ["build_output"]
      version         = "1"
      run_order       = 1
      configuration = {
        ActionMode     = "REPLACE_ON_FAILURE"
        Capabilities   = "CAPABILITY_AUTO_EXPAND,CAPABILITY_IAM"
        OutputFileName = "CreateStackOutput.json"
        #StackName      = "serverlessrepo-${var.app_name}-${split("-",var.env_name)[0]}"
        StackName      = "serverlessrepo-${var.app_name}-${var.env_name}"
        TemplatePath       = "build_output::sam-${var.env_name}-templated.yaml"
        ParameterOverrides = "${var.parameter_overrides}"
        RoleArn            = aws_iam_role.codepipeline_role.arn
      }
    }
  }

  stage {
    name = "Post_Deploy"

    action {
      name             = "Post_Deploy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["build_output"]
      version          = "1"
      output_artifacts = ["post_output"]

      configuration = {
        ProjectName = "codebuild-post-sam-build-${var.app_name}-${var.env_name}"
      }

    }

  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${local.codepipeline_name}-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role_policy.json
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_role_policy.json
}

resource "null_resource" "create_package" {
  triggers = {
    bucket    = "${var.s3_bucket}",
    aws_profile = "${var.app_name}-${var.env_type}",
    env_name    = "${var.env_name}"
    template_file = "${var.template_file}"
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    on_failure = fail
    when = create
    command    = "aws cloudformation package --template-file ${self.triggers.template_file} --s3-bucket ${self.triggers.bucket} --output-template-file ${path.module}/templates/package.yaml --profile ${self.triggers.aws_profile} && sleep 10"
  }
}

resource "aws_cloudformation_stack" "initial" {
  name          = "serverlessrepo-${var.app_name}-${var.env_name}"
  iam_role_arn = aws_iam_role.codepipeline_role.arn
  capabilities = ["CAPABILITY_AUTO_EXPAND","CAPABILITY_IAM"]
  parameters = var.stack_parameters
  template_body = file("${path.module}/templates/package.yaml")
  depends_on = [
    null_resource.create_package
  ]
}