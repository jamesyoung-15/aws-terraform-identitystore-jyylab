variable "aws_profile" {
  type        = string
  description = "AWS profile, should use organization management account"
  default     = "default"
}

variable "identity_store_users" {
  type = map(
    object({
      given_name  = string
      family_name = string
      email       = string
    })
  )
  description = "Account information"
  default = {
    "Admin" = {
      "given_name"  = "Dharok"
      "family_name" = "The Wretched"
      "email"       = "example+1@gmail.com"
    }
  }
}

# variable "all_org_accounts" {
#   type        = list(string)
#   description = "List of all active accounts in the organization"
#   # for convenience, adds ou account name as key to maps of account information
#   default     = {
#     for account in data.aws_organizations_organizational_unit_descendant_accounts.org_accounts.accounts
#     : account.name => account
#     if account.status == "ACTIVE"
#   }
# }

# variable "admin_acc_id" {
#   type = string
#   description = "Account ID of the organization management account"
#   default = "${data.aws_caller_identity.org_management_account.account_id}"
# }