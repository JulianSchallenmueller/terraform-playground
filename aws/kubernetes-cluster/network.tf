data "aws_availability_zones" "available" {
}

resource "aws_vpc" "jsa-demo" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "jsa-terraform-eks-demo-node"
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_subnet" "jsa-demo" {
  count = 2
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.jsa-demo.id

  tags = {
    Name                                        = "jsa-terraform-eks-demo-node"
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_internet_gateway" "jsa-demo" {
  vpc_id = aws_vpc.jsa-demo.id

  tags = {
    Name = "jsa-terraform-eks-demo"
  }
}

resource "aws_route_table" "jsa-demo" {
  vpc_id = aws_vpc.jsa-demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jsa-demo.id
  }
}

resource "aws_route_table_association" "jsa-demo" {
  count = 2

  subnet_id = aws_subnet.jsa-demo[count.index].id
  route_table_id = aws_route_table.jsa-demo.id
}