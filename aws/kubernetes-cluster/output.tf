output "subnet-ids" {
    value = tolist("${aws_subnet.jsa-demo.*.id}")
}

output "sg-id" {
    value = aws_security_group.jsa-demo-cluster.id
}