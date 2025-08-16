resource "azuread_group" "groups" {
  for_each = local.users_by_department

  display_name     = each.key
  description      = "${each.key} group"
  security_enabled = true
}


resource "azuread_group_member" "memberships" {
  for_each = azuread_user.users

  group_object_id  = azuread_group.groups[each.value.department].id
  member_object_id = each.value.id
}

