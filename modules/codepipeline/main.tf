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
      name            = "Deploy_New_Stack"
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
        StackName      = "serverlessrepo-${var.app_name}-${var.env_name}"
        #TemplateConfiguration = "build_output::sam-config.yaml"
        TemplatePath       = "build_output::sam-${var.env_name}-templated.yaml"
        ParameterOverrides = "${var.parameter_overrides}"
        RoleArn            = aws_iam_role.codepipeline_role.arn
      }
    }

    dynamic "action" {
      for_each = var.run_integration_tests || var.run_stress_tests ? [1] : []
      content {
        name            = "Run_Tests"
        category        = "Invoke"
        owner           = "AWS"
        provider        = "Lambda"
        input_artifacts = ["build_output"]
        version         = "1"
        run_order       = 2
        configuration = {
          FunctionName : "${var.app_name}-${var.env_type}-test-framework-manager"
          "UserParameters" : "${var.env_name}"
        }
      }
    }

    dynamic "action" {
      for_each = var.pipeline_type != "dev" ? [1] : []
      content {
        name            = "Wait_For_Merge"
        category        = "Invoke"
        owner           = "AWS"
        provider        = "Lambda"
        input_artifacts = ["build_output"]
        version         = "1"
        run_order       = 3
        configuration = {
          FunctionName : "${var.app_name}-${var.env_type}-merge-waiter"
          "UserParameters" : "${var.env_name}"
        }
      }
    }

    dynamic "action" {
      for_each = var.pipeline_type == "dev" ? [1] : []
      content {
        name             = "Shift-Traffic"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["source_output"]
        version          = "1"
        run_order       = 4
        configuration = {
          ProjectName = "codebuild-shift-stack-sam-build-${var.app_name}-${var.env_name}"
        }
      }
    }
    action {
      name      = "Delete_Previouse_Stack"
      category  = "Deploy"
      owner     = "AWS"
      provider  = "CloudFormation"
      version   = "1"
      run_order = 5
      configuration = {
        ActionMode     = "DELETE_ONLY"
        Capabilities   = "CAPABILITY_AUTO_EXPAND,CAPABILITY_IAM"
        OutputFileName = "CreateStackOutput.json"
        StackName      = "serverlessrepo-${var.app_name}-${var.env_name}"
        RoleArn        = aws_iam_role.codepipeline_role.arn
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

