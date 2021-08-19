** In this folder you able to find a Buildspec.yml.tpl sample for SAM Deploy **
The Buildspec.yml.tpl contains number of variables that will be replaced in the ```terraform apply``` command,.

| Variable  | Value | Source | Usage | 
| --------- |:-------------:| :-------------:| :----------:|
| RUNTIME_TYPE | dotnet| pipelines.tf in your repository (/terraform/app/). | Print only. |
| RUNTIME_VERSION | 3.1 | pipelines.tf in your repository (/terraform/app/). | Print only. | 
| TEMPLATE_FILE_PATH | service/ | The path to the SAM template (template.yml) in your repository. | Used by Sam Deploy command. |
s