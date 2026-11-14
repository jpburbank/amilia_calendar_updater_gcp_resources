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

# Background processing for every Amilia webhook. The public webhook
# function only checks the token and enqueues the raw webhook body here;
# the private worker function (var.webhook_worker_function_name) runs the
# handlers. This keeps the reply to Amilia at milliseconds (slow replies
# were followed by redeliveries) and lets a failed Amilia/Calendar call
# retry instead of being dropped.
resource "google_cloud_tasks_queue" "webhook_processing" {
  project  = var.project_id
  name     = var.webhook_queue_id
  location = var.function_region

  # One task at a time: Cloud Tasks doesn't guarantee order, and two tasks
  # for the same Activity running concurrently could overwrite each other's
  # store writes. Volume is a few dozen webhooks a day, so serial
  # processing costs nothing noticeable.
  rate_limits {
    max_dispatches_per_second = 5
    max_concurrent_dispatches = 1
  }

  # Backoff 10s, 20s, ... capped at 10 min. Unlimited attempts, bounded by
  # time. The app gives up on its own at 24h (WEBHOOK_TASK_GIVE_UP_AFTER_SECONDS),
  # logging the full webhook; max_retry_duration is only a backstop.
  retry_config {
    max_attempts       = -1
    min_backoff        = "10s"
    max_backoff        = "600s"
    max_doublings      = 6
    max_retry_duration = var.webhook_task_max_retry_duration
  }

  depends_on = [google_project_service.cloudtasks]
}

resource "google_cloud_tasks_queue_iam_member" "amilia_calendar_updater_webhook_enqueuer" {
  project  = var.project_id
  location = google_cloud_tasks_queue.webhook_processing.location
  name     = google_cloud_tasks_queue.webhook_processing.name
  role     = "roles/cloudtasks.enqueuer"
  member   = "serviceAccount:${google_service_account.amilia_calendar_updater.email}"
}

# Same caveat as the reconciler invoker binding above: the worker function
# is deployed with `gcloud functions deploy`, so it must exist before this
# resource can apply. First rollout: apply the queue and enqueuer binding
# (-target), deploy the worker, then run a full `terraform apply`.
resource "google_cloud_run_service_iam_member" "amilia_calendar_updater_webhook_worker_invoker" {
  project  = var.project_id
  location = var.function_region
  service  = var.webhook_worker_function_name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.amilia_calendar_updater.email}"
}
