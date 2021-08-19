**In this folder you able to find a Buildspec.yml.tpl sample for SAM Deploy**

### 📃 Buildspec file
This Buildspec.yml.tpl is a template that should be located in your Terraform folder, beside to "pipelines.tf" file.
The Buildspec.yml configures all the steps that will be executed in your CodedBuild project as part of your Pipeline.

### Variables
This Buildspec.yml.tpl contains number of variables that will be replaced during the ```terraform apply``` execution.
The "Source" column presents the location of the value assignment, if you would like to change the value, go the the source of the var.
Additionally, if these are a unique vars without secured strings - you can set the values hardcoded as well.

| Variable  | Value | Source | Usage | 
| --------- |:-------------:| :-------------:| :----------:|
| RUNTIME_TYPE | dotnet| pipelines.tf in your repository (/terraform/app/). | Print only. |
| RUNTIME_VERSION | 3.1 | pipelines.tf in your repository (/terraform/app/). | Print only. | 
| TEMPLATE_FILE_PATH | service/ | The path to the SAM template (template.yml) in your repository. | Used by Sam Deploy command. |

### ✍🏼 Edit your Buildspec.yml.tpl
If you want to add some tests or commands in your Buildspec - you can do it, all you need to do is:
- Add a line as a Bash command in the file.
- Apply your changes (```terraform apply```).
