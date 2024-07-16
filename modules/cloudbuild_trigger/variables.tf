variable "project" {
  type        = string
  description = "The ID of the Google Cloud project."
}

variable "region" {
  type        = string
  description = "The region for the Cloud Build triggers."
  default     = "europe-west2"
}

variable "cloudbuild_trigger_branch" {
  type        = string
  description = "The branch to trigger builds from."
  default     = "main"
}

variable "github_name" {
  type        = string
  description = "The github name"
}

variable "trigger_name" {
  type        = string
  description = "The name of the trigger"
}

variable "filename" {
  type        = string
  description = "The name of the yaml file"
  default     = "cloudbuild.yaml"
}


variable "substitutions" {
  type        = map(string)
  description = "The substitutions for the trigger"
  default     = {}
}