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

# Setup Permission Sets

# Admin Permission Set
resource "aws_ssoadmin_permission_set" "admin_permission_set" {
  name             = "Permissions-Admin"
  instance_arn     = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  relay_state      = "admin"
  session_duration = "PT12H"
  tags = {
    "terraform_managed" = "true"
  }
}

# Create Permission Sets for each active account in the organization
resource "aws_ssoadmin_permission_set" "permission_sets" {
  for_each = {
    for acc_name, acc_info in local.all_org_accounts : acc_name => acc_info
    if acc_info.id != local.admin_acc_id
  }
  name             = "Permissions-${split("-", title(each.key))[0]}"
  instance_arn     = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  session_duration = "PT6H"
  tags = {
    "terraform_managed" = "true"
  }
}

# Attach Permission Set to Account

# assign sso for admin account, attaches permission set and identity store user to an organization account
resource "aws_ssoadmin_account_assignment" "account_assignments_admin" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin_permission_set.arn
  principal_id       = aws_identitystore_user.users["Admin"].user_id # Identity store user ID, Only using one user for now
  principal_type     = "USER"
  target_id          = local.admin_acc_id # ID of the organization account
  target_type        = "AWS_ACCOUNT"
}

# assign sso for sandbox accounts, attaches permission set and identity store user to an organization account
resource "aws_ssoadmin_account_assignment" "account_assignments_sandbox" {
  for_each = { for acc_name, acc_info in local.all_org_accounts : acc_name => acc_info
  if strcontains(lower(acc_name), "sandbox") }

  instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.key].arn
  principal_id       = aws_identitystore_user.users["Admin"].user_id # Identity store user ID, Only using one user for now
  principal_type     = "USER"
  target_id          = each.value.id # ID of the organization account
  target_type        = "AWS_ACCOUNT"
}

# assign sso for dev accounts, attaches permission set and identity store user to an organization account
resource "aws_ssoadmin_account_assignment" "account_assignments_dev" {
  for_each = { for acc_name, acc_info in local.all_org_accounts : acc_name => acc_info
  if strcontains(lower(acc_name), "dev") }

  instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.key].arn
  principal_id       = aws_identitystore_user.users["Admin"].user_id # Identity store user ID, Only using one user for now
  principal_type     = "USER"
  target_id          = each.value.id # ID of the organization account
  target_type        = "AWS_ACCOUNT"
}

# assign sso for test accounts, attaches permission set and identity store user to an organization account
resource "aws_ssoadmin_account_assignment" "account_assignments_test" {
  for_each = { for acc_name, acc_info in local.all_org_accounts : acc_name => acc_info
  if strcontains(lower(acc_name), "test") }

  instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.key].arn
  principal_id       = aws_identitystore_user.users["Admin"].user_id # Identity store user ID, Only using one user for now
  principal_type     = "USER"
  target_id          = each.value.id # ID of the organization account
  target_type        = "AWS_ACCOUNT"
}

# assign sso for prod accounts, attaches permission set and identity store user to an organization account
resource "aws_ssoadmin_account_assignment" "account_assignments_prod" {
  for_each = { for acc_name, acc_info in local.all_org_accounts : acc_name => acc_info
  if strcontains(lower(acc_name), "prod") }

  instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.key].arn
  principal_id       = aws_identitystore_user.users["Admin"].user_id # Identity store user ID, Only using one user for now
  principal_type     = "USER"
  target_id          = each.value.id # ID of the organization account
  target_type        = "AWS_ACCOUNT"
}

# assign sso for deployment accounts, attaches permission set and identity store user to an organization account
resource "aws_ssoadmin_account_assignment" "account_assignments_deployment" {
  for_each = { for acc_name, acc_info in local.all_org_accounts : acc_name => acc_info
  if strcontains(lower(acc_name), "deployment") }

  instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.key].arn
  principal_id       = aws_identitystore_user.users["Admin"].user_id # Identity store user ID, Only using one user for now
  principal_type     = "USER"
  target_id          = each.value.id # ID of the organization account
  target_type        = "AWS_ACCOUNT"
}

# assign sso for backup accounts, attaches permission set and identity store user to an organization account
resource "aws_ssoadmin_account_assignment" "account_assignments_backup" {
  for_each = { for acc_name, acc_info in local.all_org_accounts : acc_name => acc_info
  if strcontains(lower(acc_name), "backup") }

  instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.key].arn
  principal_id       = aws_identitystore_user.users["Admin"].user_id # Identity store user ID, Only using one user for now
  principal_type     = "USER"
  target_id          = each.value.id # ID of the organization account
  target_type        = "AWS_ACCOUNT"
}

# Attach Policy to Permission Set

# admin policy
resource "aws_ssoadmin_managed_policy_attachment" "admin_policy" {
  depends_on = [aws_ssoadmin_account_assignment.account_assignments_admin]

  instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.admin_permission_set.arn
}

# Sandbox Policy (same for all accounts)
resource "aws_ssoadmin_managed_policy_attachment" "sandbox_policy" {
  depends_on = [aws_ssoadmin_account_assignment.account_assignments_sandbox]

  for_each = { for acc_name, acc_info in local.all_org_accounts : acc_name => acc_info
  if strcontains(lower(acc_name), "sandbox") }

  instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.key].arn
}

# Dev Policy (same for all accounts for now, modify later)
resource "aws_ssoadmin_managed_policy_attachment" "dev_policy" {
  depends_on = [aws_ssoadmin_account_assignment.account_assignments_dev]

  for_each = { for acc_name, acc_info in local.all_org_accounts : acc_name => acc_info
  if strcontains(lower(acc_name), "dev") }

  instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.key].arn
}


# Testing Policy (same for all accounts for now, modify later)
resource "aws_ssoadmin_managed_policy_attachment" "test_policy" {
  depends_on = [aws_ssoadmin_account_assignment.account_assignments_test]

  for_each = { for acc_name, acc_info in local.all_org_accounts : acc_name => acc_info
  if strcontains(lower(acc_name), "test") }

  instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.key].arn
}


# Production Policy (same for all accounts)
resource "aws_ssoadmin_managed_policy_attachment" "prod_policy" {
  depends_on = [aws_ssoadmin_account_assignment.account_assignments_prod]

  for_each = { for acc_name, acc_info in local.all_org_accounts : acc_name => acc_info
  if strcontains(lower(acc_name), "prod") }

  instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.key].arn
}

# Deployment Policy
resource "aws_ssoadmin_managed_policy_attachment" "deployment_sysadmin_policy" {
  depends_on = [aws_ssoadmin_account_assignment.account_assignments_deployment]

  for_each = { for acc_name, acc_info in local.all_org_accounts : acc_name => acc_info
  if strcontains(lower(acc_name), "deployment") }

  instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/job-function/SystemAdministrator"
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.key].arn
}
resource "aws_ssoadmin_managed_policy_attachment" "deployment_dynamodb_policy" {
  depends_on = [aws_ssoadmin_account_assignment.account_assignments_deployment]

  for_each = { for acc_name, acc_info in local.all_org_accounts : acc_name => acc_info
  if strcontains(lower(acc_name), "deployment") }

  instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.key].arn
}
resource "aws_ssoadmin_managed_policy_attachment" "deployment_cloudformation_policy" {
  depends_on = [aws_ssoadmin_account_assignment.account_assignments_deployment]

  for_each = { for acc_name, acc_info in local.all_org_accounts : acc_name => acc_info
  if strcontains(lower(acc_name), "deployment") }

  instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.key].arn
}
resource "aws_ssoadmin_managed_policy_attachment" "deployment_describeorg_policy" {
  depends_on = [aws_ssoadmin_account_assignment.account_assignments_deployment]

  for_each = { for acc_name, acc_info in local.all_org_accounts : acc_name => acc_info
  if strcontains(lower(acc_name), "deployment") }

  instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AWSOrganizationsReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.key].arn
}


# Backup Policy
resource "aws_ssoadmin_managed_policy_attachment" "backup_awsbackup_policy" {
  depends_on = [aws_ssoadmin_account_assignment.account_assignments_backup]

  for_each = { for acc_name, acc_info in local.all_org_accounts : acc_name => acc_info
  if strcontains(lower(acc_name), "backup") }

  instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AWSBackupFullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.key].arn
}
resource "aws_ssoadmin_managed_policy_attachment" "backup_s3_policy" {
  depends_on = [aws_ssoadmin_account_assignment.account_assignments_backup]

  for_each = { for acc_name, acc_info in local.all_org_accounts : acc_name => acc_info
  if strcontains(lower(acc_name), "backup") }

  instance_arn       = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.key].arn
}
