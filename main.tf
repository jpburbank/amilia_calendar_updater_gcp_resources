resource "google_service_account" "amilia_calendar_updater" {
  project      = var.project_id
  account_id   = "amilia-calendar-updater"
  display_name = "Amilia Calendar Updater"
  description  = "Service account used to sync/update calendar data from Amilia. Roles are granted separately."
}
