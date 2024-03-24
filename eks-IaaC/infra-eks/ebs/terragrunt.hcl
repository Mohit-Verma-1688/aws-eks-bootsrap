
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../infra-wrc-modules/ebs"
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}



inputs = {
  env      = include.env.locals.env
  eks_name = dependency.eks.outputs.eks_name
  openid_provider_arn = dependency.eks.outputs.openid_provider_arn

  enable_ebs_csi = include.env.locals.enable_ebs_csi
  aws-ebs-csi_version = include.env.locals.aws-ebs-csi_version
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    eks_name            = "demo"
    openid_provider_arn = "arn:aws:iam::123456789012:oidc-provider"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply"]
}
dependency "ingress-nginx" {
  config_path = "../ingress-nginx"
  skip_outputs = true
}

