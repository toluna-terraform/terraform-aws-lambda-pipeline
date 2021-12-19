variable "env_name" {
    type = string
}

variable "app_name" {
    type = string
}

variable "aws_profile" {
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

variable "enable_coralogix_subscription" {
    type = bool
    default = false
}