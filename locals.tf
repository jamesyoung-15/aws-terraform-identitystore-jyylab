locals {
  # store ou names in a list (does not include nested descendants)  
  ou_names = data.aws_organizations_organizational_units.ous.children.*.name
  # get all active accounts in the organization
  all_org_accounts = { for account in data.aws_organizations_organizational_unit_descendant_accounts.org_accounts.accounts
    : account.name => account
  if account.status == "ACTIVE" }
  admin_acc_id = data.aws_caller_identity.org_management_account.account_id

  # list of account names
  account_names = data.aws_organizations_organizational_unit_descendant_accounts.org_accounts.accounts.*.name

  # ou map: key is ou name, value is ou information
  ou_map = { for ou in data.aws_organizations_organizational_units.ous.children : ou.name => ou }

}
