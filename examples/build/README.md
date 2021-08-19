**In this folder you able to find a Buildspec.yml.tpl sample for SAM Build**

The Buildspec.yml.tpl contains number of variables that will be replaced in the ```terraform apply``` command,.

| Variable  | Value | Source | Usage |
| --------- |:-------------:| :-------------:| :--------------:|
| RUNTIME_TYPE | dotnet| pipelines.tf in your repository (/terraform/app/) | Config for the CodeBuild. |
| RUNTIME_VERSION | 3.1 | pipelines.tf in your repository (/terraform/app/) | Config for the CodeBuild.| 
| ADO_USER | JenkinsArtifact | SSM parameter /app/ado_user | In use in ```nuget add source``` command. |
| ADO_PASSWORD | ****** | SSM parameter /app/ado_password | In use in ```nuget add source``` command. |
| TEMPLATE_FILE_PATH | service/ | The path to the SAM template (template.yml) in your repository | ```sam build``` command runs in this path. |