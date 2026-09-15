variable "project_id" {
  description = "GCP project ID that resources are created in."
  type        = string
  default     = "cm-calendar-506017"
}

variable "region" {
  description = "Default GCP region for regional resources."
  type        = string
  default     = "us-central1"
}

variable "event_mapping_bucket_location" {
  description = "Location for the event-ID mapping bucket. Must match the Cloud Function's region."
  type        = string
  default     = "us-west1"
}

variable "event_mapping_retention_days" {
  description = "Days after a FacilityBooking's end date before its mapping object is deleted."
  type        = number
  default     = 90
}
