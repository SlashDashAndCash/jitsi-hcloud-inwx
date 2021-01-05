terraform {
  source = "git::git@github.com:SlashDashAndCash/tf_module_inwx.git?ref=v0.1.0"
}

locals {
  common_vars = merge(
    read_terragrunt_config(find_in_parent_folders("input.hcl")).inputs
  )
}

dependency "server" {
  config_path = "../server"

  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    id           = "1234567"
    ipv4_address = "240.132.93.71"
    ipv6_address = "fd9e:21a7:a92c:2323::1"
  }
}

dependencies {
  paths = ["../server"]
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
    ipv4_address = dependency.server.outputs.ipv4_address
    ipv6_address = dependency.server.outputs.ipv6_address
  }
)
