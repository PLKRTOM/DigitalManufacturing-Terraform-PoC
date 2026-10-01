module "btp_subaccount_dev" {
  source = "../../../modules/btp_subaccount"

  #  Variables from <environment>.auto.tfvars
  tenant              = var.tenant
  project_name        = var.project_name
  env                 = var.env
  region              = var.region
  directory_id        = var.directory_id
  usage               = var.usage
  cloudfoundry_memory = var.cloudfoundry_memory
  subaccount_labels   = var.subaccount_labels

  # Variables for the SAP Cloud Identity Services trust configuration
  idp             = var.idp
  idp_origin      = var.idp_origin
  idp_description = var.idp_description
}
