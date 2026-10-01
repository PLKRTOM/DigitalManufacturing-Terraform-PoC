# 1. Provision the Subaccount
resource "btp_subaccount" "this" {
  name      = "${upper(var.tenant)}_${var.project_name}_${var.env}"
  region    = var.region
  subdomain = var.tenant
  parent_id = var.directory_id
  usage     = var.usage
  labels    = var.subaccount_labels
}

# 2. Enable trust to the SAP Cloud Identity Services tenant
resource "btp_subaccount_trust_configuration" "fully_customized" {
  subaccount_id     = btp_subaccount.this.id
  identity_provider = var.idp
  name              = var.idp_origin
  description       = var.idp_description
  origin            = var.idp_origin
  link_text         = var.idp_origin
}

/* resource "btp_subaccount_trust_configuration" "sap_default_idp" {
  subaccount_id     = btp_subaccount.this.id
  identity_provider = "sap.default"

  # Disables direct selection on the logon screen
  available_for_user_logon = false
} */

# 3. Manage Entitlements (e.g., CF Runtime, DMC etc.)

resource "btp_subaccount_entitlement" "cf_environment" {
  subaccount_id = btp_subaccount.this.id
  service_name  = "cloudfoundry"
  plan_name     = "standard"
}

resource "btp_subaccount_entitlement" "dmc" {
  subaccount_id = btp_subaccount.this.id
  service_name  = "execution-dmc-sap"
  plan_name     = "production"
}

resource "btp_subaccount_entitlement" "dmc-application" {
  subaccount_id = btp_subaccount.this.id
  service_name  = "digital-manufacturing-services"
  plan_name     = "execution"
}

resource "btp_subaccount_entitlement" "cf_runtime" {
  subaccount_id = btp_subaccount.this.id
  service_name  = "APPLICATION_RUNTIME"
  plan_name     = "MEMORY"
  amount        = var.cloudfoundry_memory
}

# 4. Provision the Cloud Foundry Environment
resource "btp_subaccount_environment_instance" "cf_env" {
  subaccount_id    = btp_subaccount.this.id
  name             = "${var.tenant}-icf"
  environment_type = "cloudfoundry"
  service_name     = "cloudfoundry"
  plan_name        = "standard"
  landscape_label  = "cf-${var.region}"

  parameters = jsonencode({
    instance_name = "${var.tenant}"
  })

  depends_on = [btp_subaccount_entitlement.cf_runtime]
}

#5. Subscribe to Digital Manufacturing Services

resource "btp_subaccount_subscription" "dmc_subscription" {
  subaccount_id = btp_subaccount.this.id
  app_name      = "execution-dmc-sap"
  plan_name     = "production"
}
