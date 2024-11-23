output "caller_identity" {
  value = "AWS Caller Account ID: ${data.aws_caller_identity.org_management_account.account_id}"
}

output "portal_url" {
  value = "AWS SSO portal: https://${data.aws_ssoadmin_instances.sso_instance.identity_store_ids[0]}.awsapps.com/start"
}
