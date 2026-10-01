module "btp_subaccount_dev" {
  source = "../../../modules/btp_security"

  #  Variables from <environment>.auto.tfvars
  globalaccount           = var.globalaccount
  subaccount_id           = var.subaccount_id
  dm_role_template_app_id = var.dm_role_template_app_id
  dm_roles                = var.dm_roles

  dm_custom_roles = var.dm_custom_roles
}
