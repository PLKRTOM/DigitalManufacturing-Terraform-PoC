module "btp_subaccount_dev" {
  source = "../../../modules/btp_cloudfoundry"

  org_id       = var.org_id
  space_name   = var.space_name
  space_labels = var.space_labels
}
