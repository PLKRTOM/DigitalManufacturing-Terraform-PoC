# 1. Create CF Space

resource "cloudfoundry_space" "this" {
  name   = var.space_name
  org    = var.org_id
  labels = var.space_labels
}

# Look up the service plan ID from the Cloud Foundry marketplace
data "cloudfoundry_service_plan" "dm_execution" {
  name                  = "execution"
  service_offering_name = "digital-manufacturing-services"
}

resource "cloudfoundry_service_instance" "dm_execution_api" {
  name         = "dm-execution-api-srv"
  space        = cloudfoundry_space.this.id
  service_plan = data.cloudfoundry_service_plan.dm_execution.id
  type         = "managed"
  /*   parameters = {}
  tags       = ["dm", "api"]
  depends_on = [cloudfoundry_space.this] */
}
