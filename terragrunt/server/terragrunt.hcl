terraform {
  source = "git::git@github.com:SlashDashAndCash/tf_module_hcloud_server.git?ref=v0.1.1"
}

locals {
  common_vars = merge(
    read_terragrunt_config(find_in_parent_folders("input.hcl")).inputs
  )
}

dependency "ssh_key" {
  config_path = "../ssh_key"

  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    ssh_key_name = "default"
  }
}

dependencies {
  paths = ["../ssh_key"]
}

include {
  path = find_in_parent_folders()
}

terraform_version_constraint = read_terragrunt_config(find_in_parent_folders("versions.hcl")).terraform_version_constraint
terragrunt_version_constraint = read_terragrunt_config(find_in_parent_folders("versions.hcl")).terragrunt_version_constraint

prevent_destroy = get_env("TG_PREVENT_DESTROY", true)

inputs = merge(
  local.common_vars,
  {
    ssh_key_name = dependency.ssh_key.outputs.ssh_key_name
  }
)
