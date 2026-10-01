resource "btp_subaccount_destination_generic" "this" {
  for_each = var.destinations

  subaccount_id             = var.subaccount_id
  destination_configuration = jsonencode(each.value)
}
