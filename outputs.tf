output "amilia_calendar_updater_email" {
  description = "Email address of the amilia-calendar-updater service account."
  value       = google_service_account.amilia_calendar_updater.email
}

output "amilia_calendar_updater_id" {
  description = "Fully qualified ID of the amilia-calendar-updater service account."
  value       = google_service_account.amilia_calendar_updater.id
}
