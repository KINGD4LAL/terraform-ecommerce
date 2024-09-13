variable "project" {
  type        = string
  description = "The main project where the resources will sit"
}

variable "region" {
  type = string
  description = "The region where the resources will be created"
  default = "europe-west1"
}

variable "zone" {
    type = string
    description = "The zone where the resources will be created"
    default = "europe-west1-a"
}

variable "terraform_trigger_branch" {
  type        = string
  description = "terraform trigger branch"
  default     = "main"
}

variable "cloudbuild_notification_email" {
  type        = string
  description = "The email address to send notifications to"
  default     = "hamzahdalal12@gmail.com"
}