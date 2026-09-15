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
