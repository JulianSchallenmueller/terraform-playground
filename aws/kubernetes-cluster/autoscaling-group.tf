data "aws_ami" "jsa-eks-worker" {
   filter {
     name   = "name"
     values = ["amazon-eks-node-${aws_eks_cluster.jsa-demo.version}-v*"]
   }

   most_recent = true
   owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_region" "jsa-current" {
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We implement a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  jsa-demo-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.jsa-demo.endpoint}' --b64-cluster-ca '${aws_eks_cluster.jsa-demo.certificate_authority[0].data}' '${var.cluster-name}'
USERDATA

}

resource "aws_launch_configuration" "jsa-demo" {
  associate_public_ip_address = true
#  iam_instance_profile        = aws_iam_instance_profile.jsa-node.name
  image_id                    = data.aws_ami.jsa-eks-worker.id
  instance_type               = "m4.large"
  name_prefix                 = "jsa-terraform-eks"
  security_groups  = [aws_security_group.jsa-demo-node.id]
  user_data_base64 = base64encode(local.jsa-demo-node-userdata)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "jsa-demo" {
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.jsa-demo.id
  max_size             = 2
  min_size             = 1
  name                 = "jsa-terraform-eks-demo"
  vpc_zone_identifier  = tolist("${aws_subnet.jsa-demo.*.id}")

  tag {
    key                 = "Name"
    value               = "jsa-terraform-eks-demo"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
