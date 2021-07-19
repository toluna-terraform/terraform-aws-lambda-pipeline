variable "env_name" {
    type = string
}

variable "source_repository" {
    type = string
}

variable "trigger_branch" {
    type = string
}

variable "trigger_events" {
    type = list(string) 
}

variable "code_build_projects" {
    type = list(string)
}

variable "code_deploy_applications" {
    type = list(string)
}

variable "s3_bucket" {
    type = string
}