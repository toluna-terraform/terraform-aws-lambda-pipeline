variable "env_name" {
  type = string
}

variable "app_name" {
  type = string
}

variable "env_type" {
    type = string
}

variable "from_env" {
    type = string
}

variable "source_repository" {
  type = string
}

variable "trigger_branch" {
  type = string
}

variable "runtime_type" {
  type = string
}

variable "runtime_version" {
  type = string
}

variable "template_file_path" {
  type = string
}

variable "environment_variables" {
  type = map(string)
  default = {
    "PLATFORM" = "SAM"
  }
}

variable "solution_file_path" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "sq_enabled" {
  type    = bool
  default = false
}

variable "sq_version" {
  type    = string
  default = "4.7.0.2747"
}
variable "codedeploy_role" {
  type = string
}

variable "pipeline_type" {
  type = string
  default = "dev"
}

variable "parameter_overrides" {
  type = string
  default = "{\"Stage\":\"v1\"}"
}

variable "run_integration_tests" {
  type = bool
  default = false
}

variable "run_stress_tests" {
  type = bool
  default = false
}

variable "enable_jira_automation" {
  type = bool
  default = false
}

variable "is_managed_env" {
  type = bool
  default = false
}


variable "stack_parameters" {
 type = map(string)
 default = {
 }
}
