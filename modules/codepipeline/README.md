# terraform-aws-code-pipeline
Toluna [Terraform module](https://registry.terraform.io/modules/toluna-terraform/code-pipeline/aws/latest), which creates AWS CodePipeline resources.

## Requirements
Before you start using this module, please validate you already created:
- A connection (CodeStar connection).
- An SSM parameter named "/infra/codepipeline/connection_arn" which contains the Connection ARN as value.
- S3 bucket for the pipeline artifacts.

## Usage
```
module "code-pipeline" {
  source              = "toluna-terraform/code-pipeline/aws"
  version             = "~>0.0.6" // Change to the required version.
  env_name            = local.environment
  source_repository   = "tolunaengineering/chorus" // ORG_NAME/REPO_NAME
  s3_bucket           = aws_s3_bucket.codepipeline_bucket.bucket // Artifacts bucket you should create before using this module.
  code_build_projects = ["step1","step2"] // List of strings which are the names of your CodeBuild / CodeDeploy projects.
  trigger_branch      = "develop" // The branch that will trigger this pipeline.
  trigger_events      = ["push", "merge"] // The events that will trigger this pipeline.
}
```

