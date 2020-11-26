resource "tls_private_key" "hw1_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "hw1_key" {
  key_name   = "hw1_key"
  public_key = tls_private_key.hw1_key.public_key_openssh
}

resource "local_file" "hw1_key" {
  sensitive_content  = tls_private_key.hw1_key.private_key_pem
  filename           = "hw1_key.pem"
  file_permission    = "0400"
}
