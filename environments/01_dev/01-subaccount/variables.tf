variable "globalaccount" {
  type        = string
  description = "Global account subdomain"
}

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

variable "username" {
  type        = string
  description = "Your BTP username/email"
}

variable "password" {
  type        = string
  description = "Your BTP password"
  sensitive   = true
}

variable "idp" {
  type        = string
  description = "The Origin Key of your SAP Cloud Identity Service tenant"
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

variable "idp_url" {
  type        = string
  description = "URL of the identity provider for trust configuration"
  default     = ""
}

variable "idp_name" {
  type        = string
  description = "Name of the identity provider for trust configuration"
  default     = ""
}

variable "idp_description" {
  type        = string
  description = "Description of the identity provider for trust configuration"
  default     = ""
}

variable "idp_origin" {
  type        = string
  description = "Origin key of the identity provider for trust configuration"
  default     = ""
}
