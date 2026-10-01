variable "region" {
  type    = string
  default = "eu20"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "tenant" {
  type = string
}

variable "project_name" {
  type        = string
  description = "Identifier for the directory and subaccount"
}

variable "subaccount_labels" {
  type        = map(list(string))
  description = "A map of custom labels (key = string, value = list of strings) to assign to the subaccount."
  default     = {}
}

variable "usage" {
  type        = string
  description = "Purpose of the subaccount (e.g., USED_FOR_DEVELOPMENT, USED_FOR_PRODUCTION)"
}

variable "cloudfoundry_memory" {
  type        = number
  description = "Amount of memory to allocate for the Cloud Foundry environment"
  default     = 16
}

variable "directory_id" {
  type        = string
  description = "ID of the parent directory for the subaccount"
  default     = ""
}

variable "idp" {
  type        = string
  description = "The Origin Key of your SAP Cloud Identity Service tenant"
  default     = "apsr9dcy7.accounts.ondemand.com"
}

variable "idp_origin" {
  type        = string
  description = "Origin key of the identity provider for trust configuration"
  default     = "apsr9dcy7-application"
}

variable "idp_description" {
  type        = string
  description = "Description of the identity provider for trust configuration"
  default     = "SAP Cloud Identity Services - Application Users"
}
