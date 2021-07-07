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
}
