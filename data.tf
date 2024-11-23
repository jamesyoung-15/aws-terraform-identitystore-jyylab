# Get data from AWS

# get arn of caller (should be organization management)
data "aws_caller_identity" "org_management_account" {}

# get sso instance information
data "aws_ssoadmin_instances" "sso_instance" {}

# Get organization information

# root
data "aws_organizations_organization" "org" {}

# organizational units
data "aws_organizations_organizational_units" "ous" {
  parent_id = data.aws_organizations_organization.org.roots[0].id
}

# # nested organizational units (only nested ou is workload in my organization)
# data "aws_organizations_organizational_units" "workload_ous" {
#   parent_id = local.workload_id
# }

# # for convenience, adds ou names as key to maps of ou information (arn, name, etc.)
# data "aws_organizations_organizational_unit" "ou_list" {
#   for_each  = toset(local.ou_names)
#   parent_id = data.aws_organizations_organization.org.roots[0].id
#   name      = each.key
# }

# data "aws_organizations_organizational_unit" "workload_ou_list" {
#   for_each  = toset(local.workload_ous)
#   parent_id = local.workload_id
#   name      = each.key
# }

# get ou accounts
data "aws_organizations_organizational_unit_descendant_accounts" "org_accounts" {
  parent_id = data.aws_organizations_organization.org.roots[0].id
}

# Workload OU accounts
data "aws_organizations_organizational_unit_descendant_accounts" "workload_accounts" {
  parent_id = data.aws_organizations_organizational_units.ous.children[index(local.ou_names, "Workload")].id
}

# Setup Policies for Permission Sets for in-line policies

# Attach Policy to Permission Set