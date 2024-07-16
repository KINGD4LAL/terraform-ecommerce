locals {
  api_service_list = {
    apis = [
      "cloudbuild.googleapis.com",
      "cloudresourcemanager.googleapis.com",
      "compute.googleapis.com",
      "iam.googleapis.com",
      "logging.googleapis.com",
      "servicenetworking.googleapis.com",
      "serviceusage.googleapis.com",
      "run.googleapis.com",
      "vpcaccess.googleapis.com",
    ]
  }
}

module "project-services" {
    source = "git::https://github.com/terraform-google-modules/terraform-google-project-factory.git//modules/project_services?ref=c02c7db09cd92ddffeb586a9469d272081c46ff3"
    project_id = var.project
    activate_apis = local.api_service_list.apis
}

