provider "aws" {
  region = "us-east-1"
  # profile = var.aws_profile
}

# setup SSO users
resource "aws_identitystore_user" "users" {
  for_each          = var.identity_store_users
  identity_store_id = tolist(data.aws_ssoadmin_instances.sso_instance.identity_store_ids)[0]

  display_name = "${each.value.given_name} ${each.value.family_name}"
  user_name    = "${each.value.given_name}${each.value.family_name}"

  name {
    given_name  = each.value.given_name
    family_name = each.value.family_name
  }
  emails {
    value = each.value.email
  }
}