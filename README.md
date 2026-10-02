# SAP BTP Digital Manufacturing Terraform

Terraform configuration for managing SAP BTP subaccounts and related Digital Manufacturing services. This repository contains four reusable modules, several independently applied environment roots, and older configurations retained under `living/` and `backup/`.

> **Important: inspect the root before applying.** Some environment configurations do not currently match their module interfaces. In particular, the development subaccount source path and development connectivity/security inputs are inconsistent with the modules. See [Current readiness and known issues](#current-readiness-and-known-issues). A successful-looking plan is not a substitute for correcting these wiring problems and reviewing the intended target account.

## Contents

- [Repository layout](#repository-layout)
- [How the configuration is organized](#how-the-configuration-is-organized)
- [Prerequisites](#prerequisites)
- [Credentials and sensitive data](#credentials-and-sensitive-data)
- [Configure an environment](#configure-an-environment)
- [Run a stack](#run-a-stack)
- [Deployment sequence](#deployment-sequence)
- [Reusable modules](#reusable-modules)
- [Environment roots](#environment-roots)
- [State and backends](#state-and-backends)
- [Current readiness and known issues](#current-readiness-and-known-issues)
- [Safe operation and troubleshooting](#safe-operation-and-troubleshooting)

## Repository layout

| Path | Purpose |
| --- | --- |
| `modules/btp_subaccount/` | Creates a BTP subaccount, configures an identity-provider trust, assigns entitlements, provisions Cloud Foundry, and subscribes to Digital Manufacturing. |
| `modules/btp_security/` | Creates BTP role collections and custom roles. |
| `modules/btp_connectivity/` | Creates subaccount destinations from a map of destination configurations. |
| `modules/btp_cloudfoundry/` | Creates a Cloud Foundry space and a managed Digital Manufacturing execution service instance. |
| `environments/01_dev/` | Development roots for subaccount, security, and connectivity. Each directory is a separate Terraform root. |
| `environments/02_test/04_cloudfoundry/` | Test Cloud Foundry root. |
| `environments/09_prd/` | Production roots for subaccount, security, connectivity, and Cloud Foundry. |
| `living/` | Older, directly-authored BTP configuration and a separate `living/qas/` configuration. Not the current modular deployment path. |
| `backup/` | Older consolidated configuration, backend/variable files, and preserved Terraform artifacts. Treat as archival until its state and backend are deliberately recovered. |

The `05_cloudconnector/` and `06_cloudidentity(optional)/` production directories are placeholders in the current tree; they do not currently contain Terraform roots.

## How the configuration is organized

Terraform operates on the directory you run it from. Each environment stage above is an independent root with its own variables, provider configuration, dependency lock file (created on initialization), and state. The roots call reusable modules using local `source` paths. They do not automatically share resources or state with one another.

The intended progression is:

1. **Subaccount**: create or manage the BTP subaccount, trust, entitlements, Cloud Foundry environment, and Digital Manufacturing subscription.
2. **Security**: create Digital Manufacturing role collections and any custom roles in that subaccount.
3. **Connectivity**: configure destinations in the subaccount.
4. **Cloud Foundry**: create the space and managed execution service instance in the selected Cloud Foundry organization.

These steps are operational guidance, not an automated dependency graph. The roots have no cross-root `terraform_remote_state` data source or output contract. Operators must supply the correct subaccount ID, Cloud Foundry organization GUID, and other identifiers to the later roots. Check the BTP/Cloud Foundry consoles and the relevant root's state before passing identifiers between stages.

## Prerequisites

1. Install Terraform CLI **1.5.0 or later**. The modular BTP roots declare this minimum in their provider configuration; individual roots/modules also constrain provider versions.
2. Ensure the workstation or CI runner can reach the SAP BTP and Cloud Foundry APIs for the target landscape.
3. Have a BTP identity authorized to manage the target global account, subaccount, entitlements, subscriptions, trust configuration, and role resources. Cloud Foundry changes additionally require privileges in the target organization and space.
4. Obtain the target global-account subdomain, subaccount/directory IDs as applicable, Cloud Foundry API URL and organization GUID, and the service/identity-provider values required for that environment.
5. Make sure the required service plans are available and entitled in the target account. Terraform cannot make an unavailable regional plan usable merely by declaring it.

Provider constraints are declared separately by roots and modules. For example, the BTP modules currently constrain versions around `1.25`-`1.27`, while the Cloud Foundry module uses `cloudfoundry/cloudfoundry` `~> 1.18.0`. Run `terraform init` from the root being operated on so Terraform resolves the combined constraints and writes that root's lock file. Commit lock files for maintained roots when the team is ready to standardize provider selections.

## Credentials and sensitive data

- Never put passwords, client secrets, access tokens, or private keys in committed `.tf`, `.tfvars`, plan, or documentation files.
- The repository `.gitignore` excludes `*.tfvars`, `*.tfstate`, `*.tfstate.backup`, and `.terraform/`. This is only a convenience, not a security boundary. Confirm `git status` before every commit, and do not remove the ignores to publish local values.
- Most modular BTP provider blocks set only `globalaccount`; they do not set credentials explicitly. Configure authentication using the environment variables or OIDC mechanism supported by the installed SAP BTP provider version and your organization. Older roots under `living/` and `backup/` additionally declare username/password variables directly; do not copy that pattern into new roots.
- The Cloud Foundry provider root requires `cf_api_url`; configure its authentication using the provider's supported environment-based mechanism. Do not store credentials in the API URL or in source control.
- Marking a Terraform variable `sensitive` hides it from some CLI display, but does not remove it from Terraform state or saved plan files. Destination maps may contain authentication properties and are not marked sensitive in all roots. Treat state and plans as secret material: restrict access, encrypt backups, and use an approved remote backend for shared/production use.
- Rotate any credential that has been committed or otherwise exposed. `.gitignore` does not remove a file from Git history.

## Configure an environment

Each root declares its own variables in `variables.tf`. The current environment-specific `*.auto.tfvars` files are ignored by Git, so keep them local or provide values through an approved secrets/configuration system. Terraform automatically loads `*.auto.tfvars` files in the root working directory. Alternatively, use an explicitly named local `.tfvars` file with `-var-file` on the plan/apply commands.

Use the variable declarations in the selected root and module as the source of truth. Common values include:

| Value | Used for |
| --- | --- |
| `globalaccount` | BTP provider scope. |
| `tenant` | Subaccount subdomain and names derived by the subaccount module. It must satisfy SAP's subdomain constraints and be unique where required. |
| `project_name`, `env`, `region`, `usage`, `directory_id` | Subaccount naming, placement, purpose, and location. The subaccount module defaults `env` to `dev`, `region` to `eu20`, and `cloudfoundry_memory` to `16`. Confirm regional service availability before changing these. |
| `idp`, `idp_origin`, `idp_description` | Subaccount trust configuration for the identity provider. Use values from the correct identity tenant; do not infer them from the sample defaults. |
| `subaccount_id` | Target for security and destination configuration. Must refer to the intended subaccount. |
| `dm_role_template_app_id`, `dm_roles`, `dm_custom_roles` | Digital Manufacturing role template application ID, role-collection contents, and custom role definitions. |
| `destinations` | Map of destination keys to complete destination configuration maps. Consult SAP's destination property definitions and protect any credentials in these values. |
| `cf_api_url`, `org_id`, `space_name`, `space_labels` | Cloud Foundry API endpoint, organization GUID, created space name, and labels. |

### Example variable shapes

The following are structural examples only. Replace every placeholder with values approved for the selected environment; do not put secrets in this documentation.

Role collections use a map where each key is the collection name and each list item identifies a role and its role template:

```hcl
dm_roles = {
  "<collection-name>" = [
    {
      role_name     = "<role-name>"
      role_template = "<role-template-name>"
    }
  ]
}
```

Custom roles are a map keyed by custom role name; each value includes the role-template name, application ID, description, and attribute rules:

```hcl
dm_custom_roles = {
  "<custom-role-name>" = {
    name               = "<custom-role-name>"
    description        = "<description>"
    role_template_name = "<template-name>"
    app_id             = "<application-id>"
    attribute_list     = []
  }
}
```

Destinations use a map keyed by a local Terraform key. Each value is a full destination property map encoded by the module as JSON:

```hcl
destinations = {
  "<destination-key>" = {
    Name       = "<destination-name>"
    Type       = "HTTP"
    URL        = "https://<target-host>"
    ProxyType  = "Internet"
    # Add the authentication and other properties required by this destination.
  }
}
```

Cloud Foundry labels are a string-to-string map, for example `space_labels = { owner = "<team>" }`. The `space_developers` and `space_managers` inputs are currently declared but are not used by the module implementation; setting them does not grant users roles.

## Run a stack

Run every command from the exact stack directory. Do not run `terraform init`, `plan`, `apply`, or `destroy` from the repository root: the repository root is not a Terraform root.

Example for a development security stack in PowerShell:

```powershell
Set-Location environments/01_dev/02-security
terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
terraform show tfplan
```

Review the entire plan, including replacements and deletions, and verify the selected account and subaccount IDs. Only then apply the reviewed saved plan:

```powershell
terraform apply tfplan
```

For a root that uses a local variable file instead of auto-loaded variables:

```powershell
terraform plan -var-file="local.tfvars" -out=tfplan
terraform show tfplan
terraform apply tfplan
```

Use the same variable inputs for plan and apply. A saved plan can contain sensitive values; store it securely and remove it after use according to your organization's retention policy. `terraform apply` without a saved plan creates a new plan at apply time, so it is less suitable where a reviewed plan must be the one applied.

Useful state inspection commands, run from the same root, include:

```powershell
terraform state list
terraform state show '<resource-address>'
terraform output
```

The current roots do not declare Terraform outputs, so `terraform output` will not provide the cross-stage IDs. Use the relevant state resource attributes or the SAP consoles, then verify IDs before using them in another root. State output can expose sensitive data; do not paste it into tickets or logs without sanitizing it.

## Deployment sequence

1. **Select the exact root.** Choose one environment and stage directory from the table below. Treat similarly named roots as separate deployments.
2. **Check local inputs and authentication.** Confirm the variable file belongs to that root, credentials use the approved mechanism, and IDs/regions refer to the intended account.
3. **Initialize that root.** Run `terraform init`. If the backend configuration has changed, stop and assess whether Terraform is migrating existing state before using `terraform init -migrate-state` or `-reconfigure`.
4. **Format and validate.** Run `terraform fmt -check` and `terraform validate`. Fix configuration errors before planning; validation does not confirm permissions, service availability, or that IDs belong to the intended environment.
5. **Create and inspect a plan.** Use `terraform plan -out=tfplan` and `terraform show tfplan`. Review changes with the owner of the target environment, especially for production.
6. **Apply only the reviewed plan.** Use `terraform apply tfplan`. Keep the command in the same root and state context used to create the plan.
7. **Verify the result.** Check the BTP/Cloud Foundry console and `terraform state list`. Record any required IDs for the next independent root using the team's approved handoff process.
8. **Repeat for the next stage only after verifying prerequisites.** Do not assume a resource in another root will be created or deleted as part of this run.

## Reusable modules

### `btp_subaccount`

Source: [`modules/btp_subaccount`](modules/btp_subaccount/).

The module creates `btp_subaccount.this`. Its name is generated as `UPPERCASE_TENANT_project_name_env`; the `tenant` is also used as the subdomain. It can attach the subaccount to `directory_id`, set its region and usage, and apply `subaccount_labels`.

It then creates a customized trust configuration using the supplied identity provider, origin, and description. The module also requests these entitlements:

- Cloud Foundry standard environment.
- Digital Manufacturing (`execution-dmc-sap`) production plan.
- Digital Manufacturing services (`digital-manufacturing-services`) execution plan.
- `APPLICATION_RUNTIME` memory entitlement using `cloudfoundry_memory`.

After the Cloud Foundry runtime entitlement, it provisions a standard Cloud Foundry environment named from the tenant and sets the landscape label to `cf-<region>`. Finally, it subscribes the subaccount to the `execution-dmc-sap` production application. The entitlement is an explicit dependency of the Cloud Foundry environment; other provider dependencies are determined from Terraform references.

Inputs are defined in [`modules/btp_subaccount/variables.tf`](modules/btp_subaccount/variables.tf). `tenant`, `project_name`, and `usage` are required by the module; region, environment, labels, memory, parent directory, and identity-provider values have defaults. Confirm defaults against the target account before deployment.

### `btp_security`

Source: [`modules/btp_security`](modules/btp_security/).

The module creates one `btp_subaccount_role_collection` for each key in `dm_roles`. Each list item becomes a role entry using its `role_name`, `role_template`, and the shared `dm_role_template_app_id`.

It also creates one `btp_subaccount_role` for each key in `dm_custom_roles`, setting the name from the map key and applying its role template, application ID, description, and attribute list. Attribute values and origins must correspond to valid templates and identity attributes in the target SAP service.

Inputs are in [`modules/btp_security/variables.tf`](modules/btp_security/variables.tf). `globalaccount` is declared but is not consumed by the module resources; provider scope is configured by the calling root. `subaccount_id` defaults to an empty string, but should be explicitly supplied by the root. Both role maps and the template app ID are module inputs; the current module declarations do not supply defaults for the role maps.

### `btp_connectivity`

Source: [`modules/btp_connectivity`](modules/btp_connectivity/).

For each item in `destinations`, the module creates one generic subaccount destination. The map value is serialized with `jsonencode` and passed as the destination configuration. The map key is used by Terraform to identify the instance; ensure the destination's own `Name` property is set correctly in its configuration.

Inputs are in [`modules/btp_connectivity/variables.tf`](modules/btp_connectivity/variables.tf). `destinations` defaults to an empty map, which means no destinations are created. `globalaccount` is declared but not used in the resource; the calling root configures the provider. The module does not mark destination configuration sensitive, so assume credentials can appear in plans and state.

### `btp_cloudfoundry`

Source: [`modules/btp_cloudfoundry`](modules/btp_cloudfoundry/).

The module creates a `cloudfoundry_space` with the supplied organization ID, name, and labels. It looks up the Digital Manufacturing service offering's `execution` plan, then creates a managed `cloudfoundry_service_instance` named `dm-execution-api-srv` in the new space.

Inputs are defined in [`modules/btp_cloudfoundry/variables.tf`](modules/btp_cloudfoundry/variables.tf). `org_id` and `space_name` are required; labels default to an empty map. `space_developers` and `space_managers` are declared but no role-assignment resources currently consume them. The provider is configured with `cf_api_url` in each Cloud Foundry root.

## Environment roots

| Root directory | Intended scope | Important notes |
| --- | --- | --- |
| [`environments/01_dev/01-subaccount`](environments/01_dev/01-subaccount/) | Development subaccount and services. | Currently miswired; see readiness notes below. |
| [`environments/01_dev/02-security`](environments/01_dev/02-security/) | Development Digital Manufacturing roles. | Current root does not declare/pass every required module input. |
| [`environments/01_dev/03-connectivity`](environments/01_dev/03-connectivity/) | Development destinations. | Root currently passes legacy S/4HANA-specific arguments that the destination module does not accept. |
| [`environments/02_test/04_cloudfoundry`](environments/02_test/04_cloudfoundry/) | Test Cloud Foundry space and execution service instance. | Uses the Cloud Foundry provider and a local state path. Confirm `prd.auto.tfvars` is intentional for this test root. |
| [`environments/09_prd/01-subaccount`](environments/09_prd/01-subaccount/) | Production subaccount and services. | Uses the subaccount module; no explicit backend block is present, so Terraform uses its default local state for this root. |
| [`environments/09_prd/02-security`](environments/09_prd/02-security/) | Production Digital Manufacturing roles. | Uses a local backend under `.tfstate/`. |
| [`environments/09_prd/03-connectivity`](environments/09_prd/03-connectivity/) | Production destinations. | Uses a local backend under `.tfstate/`. |
| [`environments/09_prd/04_cloudfoundry`](environments/09_prd/04_cloudfoundry/) | Production Cloud Foundry space and execution service instance. | Uses a local backend under `.tfstate/`. |

Each row is an independent Terraform execution context. Keep production changes separate from development/test changes, and do not point two roots at the same state file.

## State and backends

Most current roots with an explicit backend store state at `.tfstate/terraform.tfstate` relative to that root. The development subaccount and production subaccount roots do not declare an explicit backend, so they use Terraform's default local backend in their working directories. `living/` and the top-level `backup/` configuration also use local state unless initialized with another backend configuration.

Local state is not an appropriate shared production source of truth unless the team has an explicit, secure backup and locking process. Prefer a team-approved remote backend with encryption, access controls, and state locking before collaborative or production operation. Backend configuration is initialized per root; never change backend settings casually or delete state to resolve an initialization error.

The files under `backup/config/*.tfbackend` refer to paths such as `config/dev/terraform.tfstate` and `config/prd/terraform.tfstate`. The checked-in `backup/config/` directory does not contain those child directories, so verify where the state actually lives before initializing the archived configuration with those files. A backend path is interpreted in the context of the backend/root and should not be assumed to point at `backup/btp/dev/`.

The repository currently contains Terraform state, state backups, and a binary plan under `backup/`, as well as some environment state files. State and saved plans can contain sensitive values. Do not publish them or use the backup directory as an active stack without first confirming ownership, age, target account, and state consistency. Preserve existing state; never delete or overwrite it as a troubleshooting shortcut.

## Current readiness and known issues

The following are visible from the checked-in Terraform configuration and should be resolved or deliberately accepted before applying the affected roots:

1. **Development subaccount module path and arguments:** [`environments/01_dev/01-subaccount/main.tf`](environments/01_dev/01-subaccount/main.tf) uses `source = "../../modules"`, which resolves to a path that is not the `btp_subaccount` module. It supplies only `tenant` (hard-coded), while the intended module requires additional inputs such as `project_name` and `usage`. The production root demonstrates the likely intended module path and wiring, but do not copy it blindly without reviewing environment-specific values.
2. **Development security inputs:** [`environments/01_dev/02-security/main.tf`](environments/01_dev/02-security/main.tf) calls the security module without `dm_custom_roles`, which is a required module variable. The corresponding development root [`variables.tf`](environments/01_dev/02-security/variables.tf) does not declare that variable either. Decide whether to provide an empty map or configure the intended custom roles, then validate.
3. **Development connectivity interface mismatch:** [`environments/01_dev/03-connectivity/main.tf`](environments/01_dev/03-connectivity/main.tf) supplies S/4HANA-specific arguments (`s4hana_destination_name`, URL, client ID, and secret), but [`modules/btp_connectivity`](modules/btp_connectivity/) accepts a `destinations` map instead. The unused `s4hana_client_secret` variable is sensitive, but that alone does not protect any value written to state. Align the root with the generic destination interface or intentionally implement a corresponding module contract.
4. **Cloud Foundry role inputs are not implemented:** the Cloud Foundry variables include developer and manager lists, but the module creates no role assignments. Supplying these lists currently has no effect.
5. **No root outputs or automatic stage handoff:** roots do not expose subaccount IDs, org IDs, or other values as outputs, and no cross-root state data sources are configured. Provide and verify these values explicitly before operating a later stage.
6. **Provider/backend drift:** provider constraints vary by root/module. Some roots use `.tfstate/terraform.tfstate`, while others use default local state. Initialize, inspect, and back up each root independently; do not assume the root-level `backup/config` backend files apply to the environment directories.

Run `terraform validate` in each intended root after addressing its wiring. Validation only checks Terraform configuration and provider schemas; a real plan still requires working credentials and may query SAP APIs. Never use `terraform apply` as a way to find out whether a root is ready.

## Safe operation and troubleshooting

- **Wrong account or subaccount:** stop before apply. Recheck `globalaccount`, region, `subaccount_id`, `directory_id`, `org_id`, API URL, and the state file selected by the working directory.
- **Missing variable:** inspect that root's `variables.tf` and module call. Supply a value in the local `*.auto.tfvars` file or via `-var-file`; do not solve it by committing credentials.
- **Unsupported module argument or missing module argument:** compare the root's module block with that module's `variables.tf`. Do not assume similarly named variables in another root are accepted.
- **Provider initialization or version conflict:** run `terraform init` in the selected root, review the merged root/module constraints, and preserve the resulting lock file for reproducibility. Do not delete `.terraform.lock.hcl` as a first-line fix.
- **Backend migration prompt:** pause and confirm the source and destination state locations with the state owner. Use `-reconfigure` or `-migrate-state` only when the intended state transition is understood and approved.
- **Plan shows replacement or deletion:** stop, inspect the exact resource and state, and confirm whether the change is expected. A changed name, ID, provider version, or wrong state can cause destructive plans.
- **Authentication/authorization error:** verify the provider-supported auth configuration, identity origin, and role grants for the API operation. Never paste tokens or unredacted provider logs into an issue.
- **Destroy:** `terraform destroy` removes only resources tracked in that root's state, not necessarily every related resource created by other roots. It may delete production resources. Require explicit change approval and a reviewed destroy plan; do not run it as cleanup without understanding dependencies.

For provider-specific arguments and authentication, consult the documentation matching the exact provider versions selected in that root's `.terraform.lock.hcl`.