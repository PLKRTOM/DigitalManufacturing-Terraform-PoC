variable "globalaccount" {
  type        = string
  description = "Global account subdomain"
}

variable "subaccount_id" {
  type        = string
  description = "ID of the BTP Subaccount"
  default     = ""
}

variable "dm_role_template_app_id" {
  type        = string
  description = "DM app ID of the role template"
}

variable "dm_roles" {
  type = map(list(object({
    role_name     = string
    role_template = string
  })))
  description = "Roles to be assigned to the subaccount role collection"
}
