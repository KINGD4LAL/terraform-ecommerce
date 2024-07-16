locals {
  cloud_trigger_branch_mapping = {
    "ecommerce_prod"    = "prod"
    "ecommerce_preprod" = "preprod"
    "ecommerce_dev"     = "main"
  }
}

resource "google_cloudbuild_trigger" "trigger" {
  name     = var.trigger_name
  project  = var.project
  location = var.region
    
  github {
    owner = "KINGD4LAL"
    name  = "terraform-ecommerce"
    push {
      branch = try(local.cloud_trigger_branch_mapping[var.project], var.cloudbuild_trigger_branch)
    }
  }

  substitutions = var.substitutions
  
  filename = var.filename
}
