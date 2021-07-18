variable "env_name" {
    type = string
    default = "devops"
}

variable "source_repository" {
    type = string
    default = "tolunaengineering/responses"
}

variable "trigger_branch" {
    type = string
    default = "pipeline-1.0.0"
 }

variable "src_path" {
    type = string
    default = "service/"
} 

variable "runtime_type" {
    type = string
    default = "dotnet"
}

variable "runtime_version" {
    type = string
    default = "3.1"
}

variable "template_file_path" {
    type = string
    default = "service/ResponsesService"
}

variable "environment_variables" {
 type = map(string)
 default = {
    "TEST_VAR" = "TEST_VAR_VALUE"
 }
}