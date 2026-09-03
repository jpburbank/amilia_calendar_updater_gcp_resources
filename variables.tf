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
