variable "globalaccount" {
  type        = string
  description = "Global account subdomain"
}

variable "subaccount_id" {
  type        = string
  description = "ID of the BTP Subaccount"
  default     = ""
}

variable "destinations" {
  type        = map(map(any))
  description = "Map of destination identifiers to their complete configuration maps"
  # sensitive   = true
}
