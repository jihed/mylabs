provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu_bionic" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name = "name"

    values = [
      "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*",
    ]
  }
}

resource "aws_key_pair" "labkey" { 
 key_name   = "keypair_lab_one"
 public_key = var.payload
}

data "template_file" "startup" {
 template = file("ssm-agent-install.sh")
}

module "controllers" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-ec2-instance.git"

  count = var.controller_number

  name                        = "controller"
  ami                         = data.aws_ami.ubuntu_bionic.id
  instance_type               = "m5.large"
  subnet_id                   = module.vpc.public_subnets[count.index]
  vpc_security_group_ids      = [module.vpc.default_security_group_id]
  associate_public_ip_address = true
  key_name = aws_key_pair.labkey.key_name
  user_data = data.template_file.startup.rendered

  
  tags = {
    "Patch Group"      = "DEV"
  }
}

resource "aws_volume_attachment" "controller_this" {
  count = var.controller_number

  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.controller_this[count.index].id
  instance_id = element(module.controllers[count.index].id, 0)
}

resource "aws_ebs_volume" "controller_this" {
  count = var.controller_number

  availability_zone = element(module.controllers[count.index].availability_zone, 0)
  size              = 20
}

module "nodes" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-ec2-instance.git"

  count = var.node_number

  name                        = "node"
  ami                         = data.aws_ami.ubuntu_bionic.id
  instance_type               = "m5.large"
  subnet_id                   = module.vpc.public_subnets[count.index]
  vpc_security_group_ids      = [module.vpc.default_security_group_id]
  associate_public_ip_address = true
  key_name = aws_key_pair.labkey.key_name
  user_data = data.template_file.startup.rendered


  tags = {
    "Patch Group"      = "DEV"
  }
}

resource "aws_volume_attachment" "node_this" {
  count = var.node_number

  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.node_this[count.index].id
  instance_id = element(module.nodes[count.index].id, 0)
}

resource "aws_ebs_volume" "node_this" {
  count = var.node_number

  availability_zone = element(module.nodes[count.index].availability_zone,0)
  size              = 20
}
