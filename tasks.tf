resource "google_project_service" "cloudtasks" {
  project            = var.project_id
  service            = "cloudtasks.googleapis.com"
  disable_on_destroy = false
}

# Fans out a Program's Online flip to one small async task per Activity —
# see reconcile_queue.py / reconcile_worker.py in the app repo. A Program's
# activity list can realistically run into the low hundreds, so this is
# not optional infrastructure: processing that inline in the webhook
# handler risks the response taking long enough that Amilia (or our own
# Cloud Function timeout) gives up and retries mid-fan-out.
resource "google_cloud_tasks_queue" "activity_reconciliation" {
  project  = var.project_id
  name     = var.reconcile_queue_id
  location = var.function_region

  rate_limits {
    max_dispatches_per_second = 10
    max_concurrent_dispatches = 10
  }

  retry_config {
    max_attempts = 5
  }

  depends_on = [google_project_service.cloudtasks]
}

resource "google_cloud_tasks_queue_iam_member" "amilia_calendar_updater_enqueuer" {
  project  = var.project_id
  location = google_cloud_tasks_queue.activity_reconciliation.location
  name     = google_cloud_tasks_queue.activity_reconciliation.name
  role     = "roles/cloudtasks.enqueuer"
  member   = "serviceAccount:${google_service_account.amilia_calendar_updater.email}"
}

# The reconciler Cloud Function (amilia-activity-reconciler) is deployed
# the same way as the main webhook function — via `gcloud functions
# deploy`, not Terraform — so this binding references it by name rather
# than a resource reference. It must already exist for this specific
# resource to apply cleanly: deploy the function once, then run
# `terraform apply` again if this was part of the very first apply.
resource "google_cloud_run_service_iam_member" "amilia_calendar_updater_reconciler_invoker" {
  project  = var.project_id
  location = var.function_region
  service  = "amilia-activity-reconciler"
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.amilia_calendar_updater.email}"
}
