resource "aws_eks_cluster" "jsa-demo" {
  name = var.cluster-name
  role_arn = aws_iam_role.jsa-tf-eks-master.arn

  vpc_config {
    security_group_ids = tolist("${aws_security_group.jsa-demo-cluster.*.id}")
    subnet_ids         = tolist("${aws_subnet.jsa-demo.*.id}")
  }

  depends_on = [
    aws_iam_role_policy_attachment.jsa-tf-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.jsa-tf-cluster-AmazonEKSServicePolicy,
  ]
}