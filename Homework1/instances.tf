data "template_file" "consulserver" {
  template = file("scripts/consul-server.sh")
  vars = {
    CONSUL_VERSION = "1.8.5"
  }
}
data "template_file" "consulagent" {
  template = file("scripts/consul-agent.sh")
  vars = {
    CONSUL_VERSION = "1.8.5"
  }
}
data "template_file" "webserver" {
  template = file("scripts/install_nginx.sh")
}
data "template_cloudinit_config" "web-agent" {
  gzip = false
  base64_encode = false
  part {
#filename = “userdata.ps1”
#content_type = “text/cloud-config”
    content = data.template_file.consulagent.rendered
  }
  part {
#filename = “userdata1.ps1”
#content_type = “text/cloud-config”
    content = data.template_file.webserver.rendered
  }
}

resource "aws_instance" "consul_server" {

  count         = 3

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.hw1_key.key_name

  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids = [aws_security_group.consul.id]

  tags = {
    Name = "consul-server${count.index}"
    consul_server = "true"
  }
  user_data = data.template_file.consulserver.rendered
}


resource "aws_instance" "consul_agent" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.hw1_key.key_name

  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids = [aws_security_group.consul.id]

  tags = {
    Name = "consul-agent-web-server"
  }
  user_data = data.template_cloudinit_config.web-agent.rendered
}


output "consul-servers" {
  value = aws_instance.consul_server.*.public_dns
}

output "consul-agent_web-server" {
  value = aws_instance.consul_agent.public_dns
}
