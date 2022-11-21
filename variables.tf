variable "env_name" {
  type = string
}

variable "app_name" {
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
