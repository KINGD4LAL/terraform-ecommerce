variable "project" {
  type        = string
  description = "The ID of the Google Cloud project."
}

variable "service_account" {
  type        = string
  description = "The service account for the Cloud Build triggers."
}

variable "region" {
  type        = string
  description = "The region for the Cloud Build triggers."
  default     = "global"
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

variable "github_owner" {
  type        = string
  description = "The Owner of the github repo"
  default     = "KINGD4LAL"
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