# 1. Isolate the project in a Directory
resource "btp_directory" "project_dir" {
  name        = var.project_name
  description = "Parent directory for ${var.project_name} environments"
}

# 2. Provision the Subaccount
resource "btp_subaccount" "dev" {
  name      = "${var.tenant}-'KGIT'-${var.project_name}-${var.env}"
  subdomain = var.tenant
  region    = var.region
  parent_id = btp_directory.project_dir.id
}

resource "btp_subaccount_entitlement" "alert_notification_service" {
  subaccount_id = btp_subaccount.dev.id
  service_name  = "alert-notification"
  plan_name     = "free"
}

resource "btp_subaccount_entitlement" "cf_environment" {
  subaccount_id = btp_subaccount.dev.id
  service_name  = "cloudfoundry"
  plan_name     = "standard"
}

# 4. Assign Entitlements (e.g., CF Runtime)
resource "btp_subaccount_entitlement" "cf_runtime" {
  subaccount_id = btp_subaccount.dev.id
  service_name  = "APPLICATION_RUNTIME"
  plan_name     = "MEMORY"
  amount        = 16
}


# 5. Provision the Environment
resource "btp_subaccount_environment_instance" "cf_env" {
  subaccount_id    = btp_subaccount.dev.id
  name             = "${var.tenant}-cf-${var.env}"
  environment_type = "cloudfoundry"
  service_name     = "cloudfoundry"
  plan_name        = "standard"
  // landscape_label  = "cf-${var.region}"

  parameters = jsonencode({
    instance_name = "${var.tenant}-cloudfoundry-${var.env}"
  })

  depends_on = [btp_subaccount_entitlement.cf_runtime]
}

# 6. Assign Administrators
resource "btp_subaccount_role_collection_assignment" "admins" {
  for_each             = toset(var.admins)
  subaccount_id        = btp_subaccount.dev.id
  role_collection_name = "Subaccount Administrator"
  user_name            = each.value
}
