variable "env_name" {
    type = string
}

variable "env_type" {
    type = string
}

variable "source_repository" {
    type = string
}

variable "app_name" {
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

variable "parameter_overrides" {
  type = string
}

variable "pipeline_type" {
   type = string 
}

variable "run_integration_tests" {
  type = bool
}

variable "run_stress_tests" {
  type = bool
}