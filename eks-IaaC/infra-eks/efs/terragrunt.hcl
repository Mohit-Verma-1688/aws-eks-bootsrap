#terraform {
#  source = "git@github.com:Mohit-Verma-1688/infrastucture-modules.git//eks?ref=eks-v0.0.2"
#}

locals {
  vpc_config = read_terragrunt_config("../vpc/terragrunt.hcl")
}

include "root" {
  path = find_in_parent_folders()
}


terraform {
  source = "../../infra-wrc-modules/efs"
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}



inputs = merge(
  
  local.vpc_config.inputs,
   {
   enable_efs = include.env.locals.enable_efs
   efs_name =  "dev"
   env =  include.env.locals.env
   vpc_id = dependency.vpc.outputs.vpc_id
  # vpc_block = vpc_cidr_block
  # vpc_block = dependency.vpc.outputs.vpc_cidr_block    #need to check how to import
   private_sub  = dependency.vpc.outputs.private_subnet_ids
}
)


dependency "ebs" {
  config_path = "../ebs"
  skip_outputs = true
}
dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    private_subnet_ids = ["subnet-1234", "subnet-5678"]
    vpc_id = "12345"
    vpc_cidr_block = "10.0.0.0/16"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply"]
}
