variable "env_name" {
    type = string
    default = "devops-ecs-pipe"
}

variable "source_repository" {
    type = string
    default = "tolunaengineering/chorus"
}

variable "trigger_branch" {
    type     = string
 }

variable "src_path" {
    type = string
    default = "service/"
} 

variable "lambda_name" {
    type = string
}

variable "environment_variables_parameter_store" {
 type = map(string)
 default = {
 "ADO_USER" = "/app/ado_user",
 "ADO_PASSWORD" = "/app/ado_password"
 }
}
