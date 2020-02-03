resource "aws_iam_role" "jsa-demo-node" {
  name = "jsa-terraform-eks-demo-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect" : "Allow",
          "Principal": {
              "Service": "eks.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
      }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "jsa-demo-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.jsa-demo-node.name
}

resource "aws_iam_role_policy_attachment" "jsa-demo-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.jsa-demo-node.name
}
