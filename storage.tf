resource "google_storage_bucket" "amilia_calendar_event_mappings" {
  project                     = var.project_id
  name                        = "${var.project_id}-amilia-calendar-event-mappings"
  location                    = var.event_mapping_bucket_location
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      days_since_custom_time = var.event_mapping_retention_days
      matches_prefix         = ["FacilityBooking/"]
    }
  }

  # No rule for Program/ — Programs are only ever removed by an explicit
  # Delete (archive) webhook, never auto-expired; see docs/gcs-event-store-plan.md.
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      days_since_custom_time = var.activity_mapping_retention_days
      matches_prefix         = ["Activity/"]
    }
  }
}

resource "google_storage_bucket_iam_member" "amilia_calendar_updater_event_mappings_admin" {
  bucket = google_storage_bucket.amilia_calendar_event_mappings.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.amilia_calendar_updater.email}"
}
