** In this folder you able to find a Buildspec.yml.tpl sample for SAM Build **
The Buildspec.yml.tpl contains number of variables that will be replaced in the ```terraform apply``` command,.

| Variable  | Value | Source | 
| --------- |:-------------:| :-------------:|
| RUNTIME_TYPE | dotnet| | pipelines.tf in your repository (/terraform/app/) |
| RUNTIME_VERSION | 3.1 |  | pipelines.tf in your repository (/terraform/app/) | 
| ADO_USER | JenkinsArtifact | SSM parameter /app/ado_user |
| ADO_PASSWORD | ****** | SSM parameter /app/ado_password | 
| TEMPLATE_FILE_PATH | service/ | The path to the SAM template (template.yml) in your repository |