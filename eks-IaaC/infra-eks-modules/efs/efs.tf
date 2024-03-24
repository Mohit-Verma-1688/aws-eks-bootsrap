resource "aws_efs_file_system" "efs" {
   count = var.enable_efs ? 1 : 0
   creation_token = "efs-storage"
   performance_mode = "generalPurpose"
   throughput_mode = "bursting"
   encrypted = "true"
 tags = {
     Name = var.efs_name
     Env = var.env
   }
 }

resource "aws_security_group" "efs" {
  name        = "${var.env} efs"
  description = "Allow traffic"
  vpc_id      =  var.vpc_id
  ingress {
    description      = "nfs"
    from_port        = 2049
    to_port          = 2049
    protocol         = "TCP"
    cidr_blocks      =  [var.vpc_cidr_block]
  }
}



resource "aws_efs_mount_target" "mount" {
    #count = var.enable_efs ? 1 : 0
    file_system_id = aws_efs_file_system.efs[0].id
    subnet_id = each.key
    for_each =   toset([ for v in var.private_sub : v 
                       if var.enable_efs
                       ]) 
#   for_each =   toset(var.private_sub)
    security_groups = [aws_security_group.efs.id]
}
