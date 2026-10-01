resource "btp_subaccount_role" "custom" {
  for_each = var.dm_custom_roles

  subaccount_id = var.subaccount_id
  name          = each.key

  role_template_name = each.value.role_template_name
  description        = each.value.description
  app_id             = each.value.app_id
  attribute_list = [
    for attribute in each.value.attribute_list : {
      attribute_name         = attribute.attribute_name
      attribute_value_origin = attribute.attribute_value_origin
      attribute_values       = attribute.attribute_values
    }
  ]
}

resource "btp_subaccount_role_collection" "dm" {
  for_each = var.dm_roles

  subaccount_id = var.subaccount_id
  name          = each.key

  roles = [
    for role in each.value : {
      name                 = role.role_name
      role_template_name   = role.role_template
      role_template_app_id = var.dm_role_template_app_id
    }
  ]
}
