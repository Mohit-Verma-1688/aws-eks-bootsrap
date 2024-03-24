locals {

# Enviornment prefix 
    env = "dev"

#  Make false for the component not to deploy during bootstraping.
    enable_ebs_csi = "true"
    ingress-controller = "true"
    enable_efs = "true"
    enable_efs_csi = "true"
  
# Helm versions used for the infra components.name
    aws-ebs-csi_version = "v1.18.0-eksbuild.1"
    ingress-controller_helm_verion = "4.0.1"
    aws-efs-csi_version = "2.5.6"
    
}
