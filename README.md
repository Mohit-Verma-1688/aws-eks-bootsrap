# aws-eks-bootsrap
This repo guides you to bootstrap the EKS cluster with EBS, EFS and Nginx ingress controller using terragrunt and terraform.  Terragrunt is a tool on top of the terraform to manage the IaaC neat and clean. This code also saves the terraform state in S3 backend with state lock in the dynamoDB.

## 1. Prepare the enviornment to bootstrap the EKS cluster using Terraform and Terragrunt.


- Prepare the AWS account and login to the console, create a user, policy and a role, then attach that role to policy to assing to user. Make sure to provide that user admin rights. This part needs some prior AWS IAM knowledge.
  * Refernece AWS docs -
    * https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html
    * https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html
    * https://www.youtube.com/watch?v=7wRqtBMS6E0
    * https://www.youtube.com/watch?v=yduHaOj3XMg&t=65s
- Install the terragrunt, terraform and eks cli, aws cli.
  * Terraform:  https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
  * Terragrunt:  https://terragrunt.gruntwork.io/docs/getting-started/install/
  * aws cli:  https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
  * eks cli:  https://eksctl.io/installation/
- Set the env variable in the shell AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY. These are needed to access the aws services using cli. Check the path  ~/.aws/config for more details. 
- In eks-IaaC/infra-eks/terragrunt.hcl change the role arn to the role having the admin right. 

```

~/Documents/STUDY-Mac/infra-eks/eks-IaaC/infra-eks ❯ terragrunt version           
Terraform v1.5.7
                                 
~/Documents/STUDY-Mac/infra-eks/eks-IaaC/infra-eks ❯  terraform version                                                
Terraform v1.5.7

~/Documents/STUDY-Mac/infra-eks/eks-IaaC/infra-eks ❯ cat eks-IaaC/infra-eks/terragrunt.hcl

role_arn = "arn:aws:iam::8XXXXXXXXXX:role/terraform"   --> update here 
  assume_role {
    role_arn = "arn:aws:iam::8XXXXXX:role/terraform"   --> update here


```

## 2. Bootstrap the AWS-EKS cluster using cli. 


- Git clone the directory and follow `eks-IaaC` folder . Please see the directory structure uploaded in the repo. 
- The  `infra-eks` directory contains the high level parameters for bootstrap like ansible localhost.yaml. Directory `infra-eks-modules` contains the actual aws code for the deployment.
- The default parameters can be changed for each module by modifying terragrunt.hcl file in infra-eks/`component`. For example 
  in `infra-eks/eks/terragrunt.hcl` file change the eks_version from 1.26 to 1.27. 

```

 ~/Documents/STUDY-Mac/infra-eks ❯ tree eks-IaaC -d                                                                                  
eks-IaaC
├── infra-eks
│   ├── ebs
│   ├── efs
│   ├── eks
│   ├── eks-efs-csi-driver
│   ├── ingress-nginx
│   └── vpc
└── infra-eks-modules
    ├── ebs
    ├── efs
    ├── eks
    ├── eks-efs-csi-driver
    ├── ingress-nginx
    └── vpc
```
- Go to path infra-eks and run the command terragrunt run-all appy. Select 'y' to deploy 
- This script will install the S3 bucket to store terraform state, VPC, EKS cluster, Nginx Ingress controller, EBS CSI
  ( block storage), EFS (FS storage) and EFS CSI provisioner.

```

~/Documents/STUDY-Mac/infra-eks/eks-IaaC/infra-eks ❯ terragrunt run-all apply                                                       
INFO[0000] The stack at /Users/mverma/Documents/STUDY-Mac/infra-eks/eks-IaaC/infra-eks will be processed in the following order for command apply:
Group 1
- Module /Users/mverma/Documents/STUDY-Mac/infra-eks/eks-IaaC/infra-eks
- Module /Users/mverma/Documents/STUDY-Mac/infra-eks/eks-IaaC/infra-eks/vpc

Group 2
- Module /Users/mverma/Documents/STUDY-Mac/infra-eks/eks-IaaC/infra-eks/eks

Group 3
- Module /Users/mverma/Documents/STUDY-Mac/infra-eks/eks-IaaC/infra-eks/ingress-nginx

Group 4
- Module /Users/mverma/Documents/STUDY-Mac/infra-eks/eks-IaaC/infra-eks/ebs

Group 5
- Module /Users/mverma/Documents/STUDY-Mac/infra-eks/eks-IaaC/infra-eks/efs

Are you sure you want to run 'terragrunt apply' in each folder of the stack described above? (y/n) y
Acquiring state lock. This may take a few moments...
Acquiring state lock. This may take a few moments...

 .
 .
 .
 
Apply complete! Resources: 28 added, 0 changed, 0 destroyed.

Outputs:

private_subnet_ids = [
  "subnet-0dac97b35638fcc0f",
  "subnet-00af84e840bd0b083",
]
public_subnet_ids = [
  "subnet-00a065c98fc1732f9",
  "subnet-0132f2bdb4ba150aa",
]
vpc_cidr_block = "10.0.0.0/16"
vpc_id = "vpc-09cf32f1c021cda01"
efs_file_system_id = "fs-04d9cbe9f052a6efb"



```

## 3. After 15-20 mins the EKS cluster will be created in us-west-2 along with all the required components.

- Download the kubeconfig for the cluster, make sure to use --profile tag to provide your credentials.
  * check the example "aws eks update-kubeconfig command below.
- Check the all the pods should be in running state.


```
 
 # Download the kubeconfig file for the new cluster deployed.

 aws eks update-kubeconfig --name dev-demo --region us-west-2  --role-arn arn:aws:iam::8XXXXXXXXX:role/terraform --profile terraform

~/Documents/STUDY-Mac/infra-eks/eks-IaaC/infra-eks ❯ kubectl get pods -A  
                                                        
NAMESPACE       NAME                                            READY   STATUS    RESTARTS   AGE
ingress-nginx   dev-ingress-nginx-controller-799bc6c959-fbxbh   1/1     Running   0          168m
kube-system     aws-node-2jhs8                                  2/2     Running   0          169m
kube-system     aws-node-pgz8j                                  2/2     Running   0          170m
kube-system     coredns-8fd5d4478-7c2nh                         1/1     Running   0          171m
kube-system     coredns-8fd5d4478-m9jp7                         1/1     Running   0          171m
kube-system     ebs-csi-controller-6664d747b8-j29vb             6/6     Running   0          168m
kube-system     ebs-csi-controller-6664d747b8-pl7zb             6/6     Running   0          168m
kube-system     ebs-csi-node-bnddh                              3/3     Running   0          168m
kube-system     ebs-csi-node-pgl8m                              3/3     Running   0          168m
kube-system     efs-csi-controller-554ffb84c4-8v5bv             3/3     Running   0          117m
kube-system     efs-csi-controller-554ffb84c4-bhgjb             3/3     Running   0          117m
kube-system     efs-csi-node-hq5n8                              3/3     Running   0          117m
kube-system     efs-csi-node-jhsrq                              3/3     Running   0          117m
kube-system     kube-proxy-h2t22                                1/1     Running   0          169m
kube-system     kube-proxy-pgjrf                                1/1     Running   0          170m

```


## 4. Destroy the EKS enviornment. 


- Delete the EKS cluster and addons.

```
/Documents/STUDY-Mac/infra-eks/eks-IaaC/infra-eks ❯ terragrunt run-all destroy
INFO[0000] The stack at /Users/mverma/Documents/STUDY-Mac/infra-eks/eks-IaaC/infra-eks will be processed in the following order for command destroy:
Group 1
- Module /Users/mverma/Documents/STUDY-Mac/infra-eks/eks-IaaC/infra-eks
- Module /Users/mverma/Documents/STUDY-Mac/infra-eks/eks-IaaC/infra-eks/efs
- Module /Users/mverma/Documents/STUDY-Mac/infra-eks/eks-IaaC/infra-eks/eks-efs-csi-driver

Group 2
- Module /Users/mverma/Documents/STUDY-Mac/infra-eks/eks-IaaC/infra-eks/ebs

Group 3
- Module /Users/mverma/Documents/STUDY-Mac/infra-eks/eks-IaaC/infra-eks/ingress-nginx

Group 4
- Module /Users/mverma/Documents/STUDY-Mac/infra-eks/eks-IaaC/infra-eks/eks

Group 5
- Module /Users/mverma/Documents/STUDY-Mac/infra-eks/eks-IaaC/infra-eks/vpc

WARNING: Are you sure you want to run `terragrunt destroy` in each folder of the stack described above? There is no undo! (y/n) y
Acquiring state lock. This may take a few moments...
```
