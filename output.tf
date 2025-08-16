output "azuread_domain" {
  value = data.azuread_domains.aad.domains[*].domain_name
}

output "users" {
  value = [for user in local.users : "${user.first_name} ${user.last_name}"]
}

output "groups" {
  value = [for group in azuread_group.groups : group.display_name]
}

output "group_members" {
  value = [for group in azuread_group.groups : group.members]
}

