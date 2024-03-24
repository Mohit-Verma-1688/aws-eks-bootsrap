#terraform {
#  source = "git@github.com:Mohit-Verma-1688/infrastucture-modules.git//eks?ref=eks-v0.0.2"
#}

include "root" {
  path = find_in_parent_folders()
}


terraform {
  source = "../../infra-wrc-modules/eks"
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

inputs = {
  eks_version = "1.26"
  env         = include.env.locals.env
  eks_name    = "demo"
  subnet_ids  = dependency.vpc.outputs.private_subnet_ids

  node_groups = {
    general = {
      capacity_type  = "ON_DEMAND"
      instance_types = ["t3.large"]
      scaling_config = {
        desired_size = 2
        max_size     = 3
        min_size     = 2
      }
    }
  }
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    private_subnet_ids = ["subnet-1234", "subnet-5678"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply"]
}
