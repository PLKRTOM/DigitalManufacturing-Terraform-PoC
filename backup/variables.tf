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

variable "admins" {
  type        = list(string)
  description = "List of administrator emails"
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
