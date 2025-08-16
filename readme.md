# Azure Entra ID bootstrap with Terraform

This project provisions Azure Entra ID (Azure AD) users from a CSV and creates one security group per department, assigning each user to the corresponding department group. It uses the HashiCorp AzureAD provider and stores state remotely in Azure Storage.

Key modules and constructs:
- [data "azuread_domains" "aad"](main.tf:1) reads the tenant’s initial onmicrosoft.com domain.
- [resource "azuread_user" "users"](main.tf:5) creates users from [users.csv](users.csv).
- [locals](locals.tf:1) prepares domain and CSV-derived maps, including users_by_department.
- [resource "azuread_group" "groups"](groups.tf:1) creates one group per department.
- [resource "azuread_group_member" "memberships"](groups.tf:10) adds each user to their department group.
- [output "users"](output.tf:5), [output "groups"](output.tf:9) expose useful summaries after apply.

Repository layout

- [provider.tf](provider.tf) — Providers and required versions ([terraform](provider.tf:1), azurerm, [provider "azuread"](provider.tf:22)).
- [backend.tf](backend.tf) — Remote state backend ([terraform](backend.tf:1) backend "azurerm").
- [main.tf](main.tf) — Users and domain lookup.
- [groups.tf](groups.tf) — Department groups and memberships.
- [locals.tf](locals.tf) — Local values and CSV decoding.
- [varialbes.tf](varialbes.tf) — Input variables.
- [terraform.tfvars](terraform.tfvars) — Sample values (do not commit secrets).
- [users.csv](users.csv) — Input data file for users.

Prerequisites

- Terraform [required_version](provider.tf:9) >= 1.9.0
- Azure subscription and Entra ID tenant
- App registration with client secret for non-interactive auth
- Admin consent on Microsoft Graph application permissions:
  - User.ReadWrite.All
  - Group.ReadWrite.All
  - Directory.Read.All
- Or equivalent delegated permissions with a signed-in admin session when running terraform
- Azure Storage for remote state (see next section)

Remote state backend

The backend is configured in [backend.tf](backend.tf) to use an Azure Storage account:
- Resource Group: dev-resources
- Storage Account: ganeshdevday0413496
- Container: tfstate
- Blob key: dev.terraform.tfstate

Create these once (idempotent) with Azure CLI:

az group create -n dev-resources -l eastus
az storage account create -n ganeshdevday0413496 -g dev-resources -l eastus --sku Standard_LRS
az storage container create -n tfstate --account-name ganeshdevday0413496

Authentication options

You can supply credentials via variables in [terraform.tfvars](terraform.tfvars) or environment variables.
Variables expected in [varialbes.tf](varialbes.tf):
- subscription_id
- tenant_id
- client_id
- client_secret

Recommended environment variables (avoid committing secrets):
- ARM_CLIENT_ID or AZURE_CLIENT_ID
- ARM_CLIENT_SECRET or AZURE_CLIENT_SECRET
- ARM_TENANT_ID or AZURE_TENANT_ID
- ARM_SUBSCRIPTION_ID or AZURE_SUBSCRIPTION_ID

Example (Windows cmd.exe):

set ARM_CLIENT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
set ARM_CLIENT_SECRET=superSecretValue
set ARM_TENANT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
set ARM_SUBSCRIPTION_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

CSV input format

The file [users.csv](users.csv) must contain the header and columns:

first_name,last_name,department,job_title
Joe,Smith,Engineering,Director Technology

Behavior and naming rules

- UPN: first letter of first_name + last_name + @ + initial tenant domain from [data "azuread_domains" "aad"](main.tf:1).
  Example: Joe Smith in tenant ganeshdevday.onmicrosoft.com becomes jsmith@ganeshdevday.onmicrosoft.com via [resource "azuread_user" "users"](main.tf:5).
- Temporary password: lower(first_name) + UPPER(last_name) + length(last_name) with [force_password_change](main.tf:17) on first login.
- Display name: first_name + space + last_name.
- Department and job title are mapped directly from CSV to the user object.
- Groups: one security-enabled group per unique department through [resource "azuread_group" "groups"](groups.tf:1).
- Memberships: each user added to their department group using [resource "azuread_group_member" "memberships"](groups.tf:10).
- for_each key for users is first_name; ensure first_name values are unique in CSV, or adjust the key in [resource "azuread_user" "users"](main.tf:6) before use.

Usage

1) Initialize providers and backend

terraform init

2) Validate configuration

terraform validate

3) Plan (reads users.csv and shows changes)

terraform plan -var-file="terraform.tfvars"

4) Apply

terraform apply -var-file="terraform.tfvars"

5) Destroy (when you need to remove all managed users/groups)

terraform destroy -var-file="terraform.tfvars"

Outputs

- [output "azuread_domain"](output.tf:1): The tenant initial domain(s).
- [output "users"](output.tf:5): List of display names for created users.
- [output "groups"](output.tf:9): List of created department group names.
- [output "group_members"](output.tf:13): Group members summary.

Notes and troubleshooting

- Ensure the service principal has Graph permissions listed above and that admin consent has been granted.
- If users already exist with the same UPN, creation will fail. Modify CSV or key logic accordingly.
- The domain selected comes from [only_initial](main.tf:2) domains list and uses the first value [local.azuread_domain_name[0]](locals.tf:2).
- Consider rotating the temporary password logic before production usage; store secrets securely.
- The variables file is named [varialbes.tf](varialbes.tf) (intentional spelling in this repo).
- Never commit real secrets to version control; prefer environment variables or a secure secret store.

Clean up

To remove all resources managed by this configuration in the tenant:

terraform destroy -var-file="terraform.tfvars"

Next steps

- Parameterize the UPN and password scheme for real environments.
- Add MFA and conditional access policies outside of Terraform user bootstrap.
- Add additional attributes to CSV and map them in [resource "azuread_user" "users"](main.tf:21).
- Replace the for_each key with a stable unique identifier (e.g., email) in [resource "azuread_user" "users"](main.tf:6).

License

MIT or company-internal as applicable.