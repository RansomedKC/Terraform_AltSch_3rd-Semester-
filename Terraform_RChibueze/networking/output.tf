output "test_public_subnet" {
  value = aws_subnet.kaysee_public_subnet
}

output "allow_all" {
  value = aws_security_group.kaysee_webserver_sg
}
