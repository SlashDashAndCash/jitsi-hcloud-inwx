terraform {
  source = "git::git@github.com:SlashDashAndCash/tf_module_acme.git?ref=v0.2.1"
}

locals {
  common_vars = merge(
    read_terragrunt_config(find_in_parent_folders("input.hcl")).inputs
  )
}

include {
  path = find_in_parent_folders()
}

terraform_version_constraint = read_terragrunt_config(find_in_parent_folders("versions.hcl")).terraform_version_constraint
terragrunt_version_constraint = read_terragrunt_config(find_in_parent_folders("versions.hcl")).terragrunt_version_constraint

prevent_destroy = get_env("TG_PREVENT_DESTROY", true)

inputs = merge(
  local.common_vars
)
