data "azuread_domains" "aad" {
  only_initial = true
}

resource "azuread_user" "users" {
  for_each = { for user in local.users : user.first_name => user }
  #user principal name format (Email): firstname + lastname + domain e.g.ganesh.kumbhar@ganeshdevday.onmicrosoft.com
  user_principal_name = format("%s%s@%s", 
  lower(substr(each.value.first_name, 0, 1)), 
  lower(each.value.last_name), 
  lower(local.azuread_domain_name[0]))
  #password format: firstname + lastname + length of lastname
  password = format("%s%s%s",   
  lower(each.value.first_name),
  upper(each.value.last_name), 
  length(each.value.last_name))   
  force_password_change = true
  lifecycle {
    ignore_changes = [password]
  }
  #display name format: firstname + lastname
  display_name = "${each.value.first_name} ${each.value.last_name}" 
  department = each.value.department
  job_title = each.value.job_title
  account_enabled = true
}

