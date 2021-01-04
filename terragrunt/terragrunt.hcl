locals {
  tg_root = "${dirname(find_in_parent_folders())}"
}

remote_state {
  backend = "local"
  config = {
    path = "${local.tg_root}/../tf_state/${path_relative_to_include()}/terraform.tfstate"
  }
}
