terraform {
  source = "git::git@github.com:SlashDashAndCash/tf_module_jitsi.git?ref=v0.1.0"
}

locals {
  common_vars = merge(
    read_terragrunt_config(find_in_parent_folders("input.hcl")).inputs
  )
}

dependency "dns" {
  config_path = "../dns"
  skip_outputs = true
}

dependency "cert" {
  config_path = "../cert"

  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    fullchain_pem = <<EOT
-----BEGIN CERTIFICATE-----
-----END CERTIFICATE-----

EOT

    private_key_pem = <<EOT
-----BEGIN RSA PRIVATE KEY-----
-----END RSA PRIVATE KEY-----

EOT
  }
}

dependencies {
  paths = ["../dns", "../cert"]
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
    fullchain_pem = dependency.cert.outputs.fullchain_pem
    private_key_pem = dependency.cert.outputs.private_key_pem
  }
)
