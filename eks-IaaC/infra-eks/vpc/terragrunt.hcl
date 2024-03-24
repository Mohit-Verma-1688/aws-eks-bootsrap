#terraform {
#  source = "git::git@github.com:Mohit-Verma-1688/infrastucture-modules.git//vpc?ref=vpc-v0.0.1"
#}


include "root" {
  path = find_in_parent_folders()
}


terraform {
  source = "../../infra-wrc-modules/vpc"
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

inputs = {
  env             = include.env.locals.env
  azs             = ["us-west-2a", "us-west-2b"] 
  private_subnets = ["10.0.0.0/19", "10.0.32.0/19"]
  public_subnets  = ["10.0.64.0/19", "10.0.96.0/19"]
  vpc_cidr_block = "10.0.0.0/16"

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/dev-demo"  = "owned"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb"         = 1
    "kubernetes.io/cluster/dev-demo" = "owned"
  }
}
