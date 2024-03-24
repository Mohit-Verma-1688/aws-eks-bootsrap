data "aws_iam_openid_connect_provider" "this" {
  arn = var.openid_provider_arn
}

data "aws_iam_policy_document" "csi" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.this.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-efs-csi-driver"]
    }

    principals {
      identifiers = [data.aws_iam_openid_connect_provider.this.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "amazon_efs_csi_driver" {
  count = var.enable_efs_csi ? 1 : 0

  assume_role_policy = data.aws_iam_policy_document.csi.json
  name               = "${var.eks_name}-amazon_efs_csi_driver"
}


resource "aws_iam_role_policy_attachment" "aws-eks-addon" {
  count = var.enable_efs_csi ? 1 : 0

  role       = aws_iam_role.amazon_efs_csi_driver[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}



resource "helm_release" "aws_efs_csi_driver" {
  count = var.enable_efs_csi ? 1 : 0

  name = "${var.env}-efs-csi"

  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart      = "aws-efs-csi-driver"
  namespace  = "kube-system"
  version    = var.aws-efs-csi_version
  timeout          = "1200"
  force_update	   = true

#  values = [
#    templatefile("${path.module}/nginx-values.yaml", { env = "${var.env}" })
#  ]

  set {
    name  = "controller.serviceAccount.create"
    value = true
  }

  set {
    name  = "controller.serviceAccount.name"
    value = "aws-efs-csi-driver"
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.amazon_efs_csi_driver[0].arn
  }


}