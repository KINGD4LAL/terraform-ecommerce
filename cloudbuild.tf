module "terraform" {
    depends_on                = [module.project-services, google_project_iam_member.cloudbuild]
    source                    = "./modules/cloudbuild_trigger"
    project                   = var.project
    github_name               = "terraform-ecommerce"
    trigger_name              = "terraform-trigger"
    filename                  = "./cloudbuild/${var.project}.yaml"
    service_account           = "projects/${var.project}/serviceAccounts/${google_service_account.cloudbuild.email}"
    cloudbuild_trigger_branch = var.terraform_trigger_branch
}

resource "google_logging_metric" "cloud-build-errors" {
  name        = "cloud-build-errors"
  description = "Count of error messages in Cloud Build"
  filter      = "resource.type:\"build\" severity:\"INFO\" textPayload:\"ERROR: Build\""
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_notification_channel" "cloudbuild-notification" {
  type         = "email"
  display_name = "Cloud Notification Channel"
  labels = {
    email_address = var.cloudbuild_notification_email
  }
  force_delete = false
}

resource "google_monitoring_alert_policy" "cloudbuild" {
  project      = var.project
  display_name = "Cloud Build Error"
  combiner     = "OR"

  notification_channels = [google_monitoring_notification_channel.cloudbuild-notification.name]

  depends_on = [google_monitoring_notification_channel.cloudbuild-notification]

  documentation {
    content   = "Cloud Build Errors have been Detected"
    mime_type = "text/markdown"
  }

  conditions {
    display_name = "Cloud Build Alerts"
    condition_threshold {
      comparison      = "COMPARISON_GT"
      duration        = "0s"
      threshold_value = 0
      filter          = "metric.type=\"logging.googleapis.com/user/cloud-build-errors\" resource.type=\"build\""

      aggregations {
        per_series_aligner   = "ALIGN_MAX"
        alignment_period     = "60s"
        cross_series_reducer = "REDUCE_SUM"
      }

      trigger {
        count   = 1
        percent = 0
      }
    }
  }
}
