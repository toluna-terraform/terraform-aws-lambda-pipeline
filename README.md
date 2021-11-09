# terraform-aws-sam-pipeline
Toluna [Terraform module](https://registry.terraform.io/modules/toluna-terraform/sam-pipeline/aws/latest), which creates SAM pipeline (package & deploy).

## Requirements
Before you start using this module, please validate you already have:
- **Connection** (CodeStar connection).
- ***SSM parameter*** named "/infra/codepipeline/connection_arn" which contains the Connection ARN as value.
- ***SSM parameter*** named "/app/ado_user".
- ***SSM parameter*** named "/app/ado_password".
- ***samconfig.toml*** file in the same folder of the SAM template.
- ***"DeploymentPreference"*** property for each function in your SAM template file:
```
    Type: AWS::Serverless::Function
    Properties:
    	AutoPublishAlias: live
    	DeploymentPreference:
    		Type: Linear10PercentEvery1Minute
```
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
  template_file_path  = "service/ResponsesService" // The path of the SAM template folder.
}
```

### Samconfig template (samconfig.toml.j2)
#### Please don't forget to add the samconfig.toml file in .gitignore, to avoid uploads of static samconfig.toml to the repoisotry.
Every SAM project should contain a samconfig.toml.j2 file inside the terraform/app/ folder.
This template file is a [samconfig.toml](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-config.html) file with variables that should be set by Jinja, this is a part of the solution we have created for SAM developers so that they will be able to work according Git-Flow without required manual changes in Samconfig file (e.g. you don't need to change Env name / Stage name before every deployment or after every merge).

***The template content:***


Here is an example for Quota-Service:
```
version = 0.1
[default]
[default.deploy]
[default.deploy.parameters]
stack_name = "quota-service-{{env}}" // App-name = quota-service
s3_bucket = "s3-codepipeline-{{env}}-templatequotaservice"
region = "us-east-1"
capabilities = "CAPABILITY_IAM"
parameter_overrides = "Stage=\"{{env}}\" Version=\"v1\" CommitNumber=\"0\" Subnets=\"/infra/{{env}}/private_subnets_ids\" SecurityGroups=\"/infra/{{env}}/vpce_security_groups\""
```

#### The usage in the deployment pipeline
Inside ```buildspec-deploy.yml.tpl``` file (under ```terraform/app/``` folder) there is a command for replacing the {{env}} with the current environment which is configured in the pipeline.

```jinja2 samconfig.toml.j2 -D env=${ENV_NAME} -o samconfig.toml```

For example, if the pipeline of Prod env will be executed, before the deployment command (sam deploy) the jinja2 command will be executed like this:

```jinja2 samconfig.toml.j2 -D env=prod -o samconfig.toml```

(The replacement will be happen automatically before every deployment, no action is required from your side).

#### The usage in local mode
When you work locally and you would like to use a static samconfig.toml file, all you need to do is to select the required workspace (`terraform workspace select MYWORKSPACE`) and run `Terraform Apply`, the Terraform-Apply command  will generate automatically the samconfig.toml file under you service folder, and will set the {{env}} value according the selected workspace.

***For example:***
Execution of the next commands:
```terraform workspace select dev```
```terraform apply```

Will generate automatically a samconfig.toml file with this content:
```
version = 0.1
[default]
[default.deploy]
[default.deploy.parameters]
stack_name = "quota-service-dev" //
s3_bucket = "s3-codepipeline-dev-templatequotaservice"
region = "us-east-1"
capabilities = "CAPABILITY_IAM"
parameter_overrides = "Stage=\"dev\" Version=\"v1\" CommitNumber=\"0\" Subnets=\"/infra/dev/private_subnets_ids\" SecurityGroups=\"/infra/dev/vpce_security_groups\""
```

