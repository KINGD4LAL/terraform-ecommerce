locals {
  cloudbuild_account_roles = {
    "cloudbuild"           = "roles/cloudbuild.workerPoolUser"
    "cloudrunadmin"        = "roles/run.admin"
    "computeviewer"        = "roles/compute.viewer"
    "loggingviewer"        = "roles/logging.viewer"
    "monitoringviewer"     = "roles/monitoring.viewer"
    "roleviewer"           = "roles/iam.roleViewer"
    "serviceaccountviewer" = "roles/iam.serviceAccountViewer"
    "networkadmin"         = "roles/compute.networkAdmin"
    "vpcaccess"            = "roles/vpcaccess.user"
    "artifactregistry"     = "roles/artifactregistry.admin"
  }
}

data "google_project" "project" {}

resource "google_project_iam_member" "cloudbuild" {
  depends_on = [module.project-services]
  for_each   = local.cloudbuild_account_roles
  project    = var.project
  role       = each.value
  member     = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}