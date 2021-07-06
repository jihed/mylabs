provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "main" {
  tags = {
    Name = "aws-controltower-VPC"
  }
}
data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.main.id
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

module "security_group" {
  source = "../sg"

  name        = "example"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = data.aws_vpc.main.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

module "controllers" {
  source = "../ec2

  instance_count = var.controller_number

  name                        = "controller"
  ami                         = data.aws_ami.ubuntu_bionic.id
  instance_type               = "c5.large"
  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = true
}

resource "aws_volume_attachment" "controller_this" {
  count = var.controller_number

  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.controller_this[count.index].id
  instance_id = module.controllers.id[count.index]
}

resource "aws_ebs_volume" "controller_this" {
  # checkov:skip=CKV2_AWS_2: ADD REASON
  # checkov:skip=CKV2_AWS_9: ADD REASON
  # checkov:skip=CKV_AWS_3: ADD REASON
  count = var.controller_number

  availability_zone = module.controllers.availability_zone[count.index]
  size              = 1
}

module "nodes" {
  source = "../terraform-aws-ec2-instance"

  instance_count = var.node_number

  name                        = "node"
  ami                         = data.aws_ami.ubuntu_bionic.id
  instance_type               = "c5.large"
  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = true
}

resource "aws_volume_attachment" "node_this" {
  count = var.node_number

  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.node_this[count.index].id
  instance_id = module.nodes.id[count.index]
}

resource "aws_ebs_volume" "node_this" {
  # checkov:skip=CKV2_AWS_2: ADD REASON
  # checkov:skip=CKV2_AWS_9: ADD REASON
  # checkov:skip=CKV_AWS_3: ADD REASON
  count = var.node_number

  availability_zone = module.nodes.availability_zone[count.index]
  size              = 1
}
