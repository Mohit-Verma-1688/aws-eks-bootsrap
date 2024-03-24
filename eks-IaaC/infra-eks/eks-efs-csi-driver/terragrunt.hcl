#terraform {
#  source = "git::git@github.com:Mohit-Verma-1688/infrastucture-modules.git//ingress-nginx?ref=ingress-controller-v0.0.4"
#}

include "root" {
  path = find_in_parent_folders()
}


terraform {
  source = "../../infra-wrc-modules/eks-efs-csi-driver"
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

  enable_efs_csi  = include.env.locals.enable_efs_csi
  aws-efs-csi_version = include.env.locals.aws-efs-csi_version
}

dependency "eks" {
  config_path = "../eks"
 
  mock_outputs = {
    eks_name            = "demo"
    openid_provider_arn = "arn:aws:iam::123456789012:oidc-provider"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply"]
}

generate "helm_provider" {
  path      = "helm-provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF

data "aws_eks_cluster" "eks" {
    name = var.eks_name
}

data "aws_eks_cluster_auth" "eks" {
    name = var.eks_name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}
EOF
}
