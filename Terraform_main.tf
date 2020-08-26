# Provider
provider "aws" {
  access_key = "zzzzzzzzzzzzzzz"
  secret_key = "xxxxxxxxxxxxxxxxxxxxxxxx"
  region = "ap-northeast-2"
}

# Retrieve the AZ where we want to create network resources
data "aws_availability_zones" "available" {}

# VPC Resource
resource "aws_vpc" "main" {
  cidr_block = "10.11.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "Terraform VPC"
  }
}

# AWS subnet resource
resource "aws_subnet" "pub-az-a" {
 vpc_id = "${aws_vpc.main.id}"
 cidr_block = "10.11.1.0/24"
 availability_zone = "${data.aws_availability_zones.available.names[0]}"
 map_public_ip_on_launch = "false"
 tags = {Name = "Terraform pub-az-a"}
}

resource "aws_subnet" "pub-az-c" {
 vpc_id = "${aws_vpc.main.id}"
 cidr_block = "10.11.2.0/24"
 availability_zone = "${data.aws_availability_zones.available.names[2]}"
 map_public_ip_on_launch = "false"
 tags = {Name = "Terraform pub-az-c"}
}

resource "aws_subnet" "pri-az-a" {
 vpc_id = "${aws_vpc.main.id}"
 cidr_block = "10.11.3.0/24"
 availability_zone = "${data.aws_availability_zones.available.names[0]}"
 map_public_ip_on_launch = "false"
 tags = {Name = "Terraform pri-az-a"}
}

resource "aws_subnet" "pri-az-c" {
 vpc_id = "${aws_vpc.main.id}"
 cidr_block = "10.11.4.0/24"
 availability_zone = "${data.aws_availability_zones.available.names[2]}"
 map_public_ip_on_launch = "false"
 tags = {Name = "Terraform pri-az-c"}
}

# AWS internet resource
resource "aws_internet_gateway" "ext-igw" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    Name = "Terraform ext-igw"
  }
}

# AWS EIP resource
resource "aws_eip" "nat-eip" {
  vpc      = true
  tags = {Name = "nat-eip"}
}

# AWS NAT resource
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = "${aws_eip.nat-eip.id}"
  subnet_id     = "${aws_subnet.pub-az-c.id}"

  tags = {
    Name = "Terraform nat-gw"
  }
}

# AWS route table resource
resource "aws_route_table" "pub-rt" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ext-igw.id}"
  }
  tags = {Name = "Terraform-pub-rt"}
}

resource "aws_route_table" "pri-rt" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat-gw.id}"
  }
  tags = {Name = "Terraform-pri-rt"}
}

resource "aws_route_table_association" "pub-rt-association-a" {
  route_table_id = "${aws_route_table.pub-rt.id}"
  subnet_id      = "${aws_subnet.pub-az-a.id}"
}

resource "aws_route_table_association" "pub-rt-association-c" {
  route_table_id = "${aws_route_table.pub-rt.id}"
  subnet_id      = "${aws_subnet.pub-az-c.id}"
}

resource "aws_route_table_association" "pri-rt-association-a" {
  route_table_id = "${aws_route_table.pri-rt.id}"
  subnet_id     = "${aws_subnet.pri-az-a.id}"
}

resource "aws_route_table_association" "pri-rt-association-c" {
  route_table_id = "${aws_route_table.pri-rt.id}"
  subnet_id     = "${aws_subnet.pri-az-c.id}"
}

resource "aws_security_group" "terraform-ec2-gs" {
  vpc_id = "${aws_vpc.main.id}"
  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
  }
  tags = {Name = "terraform-ec2-gs"}
}

resource "aws_instance" "web" {
  ami           = "ami-027ce4ce0590e3c98"
  instance_type = "t3.micro"
  subnet_id = "${aws_subnet.pub-az-a.id}"
  root_block_device {
    volume_size = 11
    volume_type = "gp2"
  }
  vpc_security_group_ids = ["${aws_security_group.terraform-ec2-gs.id}"]
  key_name = "kimkey"
  tags = {Name = "Terraform ec2"}
}

resource "aws_ebs_volume" "volume2a" {
  availability_zone = "ap-northeast-2a"
  size              = 1
}

resource "aws_volume_attachment" "ebs_att-2a" {
  device_name = "/dev/sdb"
  volume_id   = "${aws_ebs_volume.volume2a.id}"
  instance_id = "${aws_instance.web.id}"
}
