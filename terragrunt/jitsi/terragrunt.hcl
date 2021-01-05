terraform {
  source = "git::git@github.com:SlashDashAndCash/tf_module_jitsi.git?ref=v0.2.0"
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
  paths = ["../server", "../dns", "../cert"]
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
    server_id       = dependency.server.outputs.id
    fullchain_pem   = dependency.cert.outputs.fullchain_pem
    private_key_pem = dependency.cert.outputs.private_key_pem
  }
)
