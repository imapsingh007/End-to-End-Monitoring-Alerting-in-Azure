variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "RG where monitoring stack will be deployed"
  type        = string
  default     = "monitoring-rg"
}

variable "action_group_email" {
  description = "E‑mail to receive alerts"
  type        = string
  default = "imapsingh007@gmail.com"
}

variable "action_group_sms" {
  description = "Phone number (E.164) for SMS alerts"
  type        = string
  default     = null
}
