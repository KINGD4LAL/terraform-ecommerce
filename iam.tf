locals {
  cloudbuild_account_roles = {
    "cloudbuild"           = "roles/cloudbuild.workerPoolUser"
    "cloudrunadmin"        = "roles/run.admin"
    "computeviewer"        = "roles/compute.viewer"
    "loggingviewer"        = "roles/logging.viewer"
    "loggingwriter"        = "roles/logging.logWriter"
    "monitoringviewer"     = "roles/monitoring.viewer"
    "roleviewer"           = "roles/iam.roleViewer"
    "serviceaccountviewer" = "roles/iam.serviceAccountViewer"
    "networkadmin"         = "roles/compute.networkAdmin"
    "vpcaccess"            = "roles/vpcaccess.user"
    "artifactregistry"     = "roles/artifactregistry.admin"
  }
}

data "google_project" "project" {}

resource "google_service_account" "cloudbuild" {
  account_id   = "cloudbuild"
  project      = var.project
  display_name = "Cloudbuild Service Account"
}

resource "google_project_iam_member" "cloudbuild" {
  depends_on = [module.project-services]
  for_each   = local.cloudbuild_account_roles
  project    = var.project
  role       = each.value
  member     = "serviceAccount:${google_service_account.cloudbuild.email}"
}

resource "google_service_account_iam_binding" "allow-cloudbuild-act-as" {
  depends_on         = [google_project_iam_member.cloudbuild]
  service_account_id = "projects/${var.project}/serviceAccounts/${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${google_service_account.cloudbuild.email}",
  ]
}

resource "google_service_account_iam_binding" "allow-cloudbuild-act-as-cloudbuild" {
  depends_on         = [google_project_iam_member.cloudbuild]
  service_account_id = "projects/${var.project}/serviceAccounts/${google_service_account.cloudbuild.email}"
  role               = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${google_service_account.cloudbuild.email}",
  ]
}