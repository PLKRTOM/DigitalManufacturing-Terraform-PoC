variable "org_id" {
  type        = string
  description = "The GUID of the Cloud Foundry Org"
}

variable "space_name" {
  type        = string
  description = "Name of the Cloud Foundry Space (e.g., dev, qa, prod)"
}

variable "space_developers" {
  type        = list(string)
  description = "List of user emails/origins to assign SpaceDeveloper role"
  default     = []
}

variable "space_managers" {
  type        = list(string)
  description = "List of user emails/origins to assign SpaceManager role"
  default     = []
}

variable "space_labels" {
  type        = map(string)
  description = "Metadata labels for the CF space"
  default     = {}
}
