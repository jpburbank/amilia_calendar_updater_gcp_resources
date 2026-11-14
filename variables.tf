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

variable "activity_mapping_retention_days" {
  description = "Days after an Activity occurrence's end date before its mapping object is deleted."
  type        = number
  default     = 90
}

variable "function_region" {
  description = "Region the Cloud Functions (webhook receiver and reconciler) are deployed in."
  type        = string
  default     = "us-west1"
}

variable "reconcile_queue_id" {
  description = "Cloud Tasks queue name for Activity visibility reconciliation fan-out."
  type        = string
  default     = "amilia-activity-reconciliation"
}

variable "webhook_queue_id" {
  description = "Cloud Tasks queue name for processing Amilia webhooks in the background."
  type        = string
  default     = "amilia-webhook-processing"
}

variable "webhook_worker_function_name" {
  description = "Name of the private Cloud Function that processes queued Amilia webhooks."
  type        = string
  default     = "amilia-webhook-worker"
}

variable "webhook_task_max_retry_duration" {
  description = "Backstop limit on how long Cloud Tasks retries one webhook task. Must exceed the app's WEBHOOK_TASK_GIVE_UP_AFTER_SECONDS (24h), so the worker always gets to make its own final attempt, logging the full webhook before giving up."
  type        = string
  default     = "90000s" # 25h
}
