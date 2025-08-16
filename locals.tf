locals {
  azuread_domain_name = data.azuread_domains.aad.domains[*].domain_name
  users = csvdecode(file("users.csv"))
  users_by_department = { for user in local.users : user.department => user... }
}
