locals {
  project_dir = "${dirname(find_in_parent_folders("input.hcl"))}"
}

remote_state {
  backend = "local"
  config = {
    path = "${local.project_dir}/tf_state/${path_relative_to_include()}/terraform.tfstate"
  }
}
