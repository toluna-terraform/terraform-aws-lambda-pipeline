# terraform-aws-sam-pipeline
Toluna [Terraform module](https://registry.terraform.io/modules/toluna-terraform/sam-pipeline/aws/latest), which creates SAM pipeline (package & deploy).

## Requirements
Before you start using this module, please validate you already created:
- A connection (CodeStar connection).
- An SSM parameter named "/infra/codepipeline/connection_arn" which contains the Connection ARN as value.

## Usage
```
module "sam-pipeline" {
  source              = "toluna-terraform/sam-pipeline/aws"
  version             = "~>0.0.2" // Change to the required version.
  env_name            = local.environment
  source_repository   = "tolunaengineering/responses" // ORG_NAME/REPO_NAME
  trigger_branch      = local.env_vars.pipeline_branch // The branch that will trigger this pipeline.
  runtime_type        = "dotnet" // https://docs.aws.amazon.com/codebuild/latest/userguide/runtime-versions.html
  runtime_version     = "3.1" // https://docs.aws.amazon.com/codebuild/latest/userguide/runtime-versions.html
  template_file_path  = "service/" // The path of the SAM template folder.
}
```

