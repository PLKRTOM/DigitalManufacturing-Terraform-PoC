variable "globalaccount" {
  type        = string
  description = "Global account subdomain"
}

variable "subaccount_id" {
  type        = string
  description = "ID of the BTP Subaccount"
  default     = ""
}

variable "s4hana_destination_name" {
  type    = string
  default = "S4HANA_ON_PREM"
}

variable "s4hana_url" {
  type        = string
  description = "Target URL or Cloud Connector endpoint"
}

# MARK SECRETS AS SENSITIVE
variable "s4hana_client_id" {
  type        = string
  description = "OAuth2 / System Client ID"
}

variable "s4hana_client_secret" {
  type        = string
  description = "OAuth2 Client Secret"
  sensitive   = true # Prevents printing in terraform plan/apply output
}
