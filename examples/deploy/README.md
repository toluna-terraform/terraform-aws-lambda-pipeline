** In this folder you able to find a Buildspec.yml.tpl sample for SAM Deploy **
The Buildspec.yml.tpl contains number of variables that will be replaced in the ```terraform apply``` command,.

| Variable  | Value | Source | 
| --------- |:-------------:| :-------------:|
| RUNTIME_TYPE | dotnet| | pipelines.tf in your repository (/terraform/app/) | 
| RUNTIME_VERSION | 3.1 |  | pipelines.tf in your repository (/terraform/app/) | 
| TEMPLATE_FILE_PATH | service/ | The path to the SAM template (template.yml) in your repository |

In this template, the RUNTIME_TYPE and RUNTIME_VERSION in use for print only.