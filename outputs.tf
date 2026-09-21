output "amilia_calendar_updater_email" {
  description = "Email address of the amilia-calendar-updater service account."
  value       = google_service_account.amilia_calendar_updater.email
}

output "amilia_calendar_updater_id" {
  description = "Fully qualified ID of the amilia-calendar-updater service account."
  value       = google_service_account.amilia_calendar_updater.id
}

output "amilia_calendar_event_mappings_bucket" {
  description = "Name of the event-ID mapping bucket, for GOOGLE_EVENT_STORE_BUCKET in env.yaml."
  value       = google_storage_bucket.amilia_calendar_event_mappings.name
}

output "amilia_webhook_token_secret_id" {
  description = "Secret Manager secret ID holding the Amilia webhook shared-secret token. Fetch the value with: gcloud secrets versions access latest --secret=<this>"
  value       = google_secret_manager_secret.amilia_webhook_token.secret_id
}

output "amilia_api_username_secret_id" {
  description = "Secret Manager secret ID for the dedicated Amilia API user's username. Set the value with: gcloud secrets versions add <this> --data-file=-"
  value       = google_secret_manager_secret.amilia_api_username.secret_id
}

output "amilia_api_password_secret_id" {
  description = "Secret Manager secret ID for the dedicated Amilia API user's password. Set the value with: gcloud secrets versions add <this> --data-file=-"
  value       = google_secret_manager_secret.amilia_api_password.secret_id
}

output "reconcile_queue_id" {
  description = "Cloud Tasks queue ID, for RECONCILE_QUEUE_ID in env.yaml."
  value       = google_cloud_tasks_queue.activity_reconciliation.name
}
