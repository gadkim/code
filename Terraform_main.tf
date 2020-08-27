# VPC-DEV config
# Provider
provider "aws" {
  access_key = "xxxxxxxxxxxxx"
  secret_key = "zzzzzzzzzzzzzzzzzzzzz"
  region = "ap-northeast-2"
}

# Retrieve the AZ where we want to create network resources
data "aws_availability_zones" "available-dev" {}

# VPC Resource
resource "aws_vpc" "main-dev" {
  cidr_block = "10.11.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "Terraform VPC"
  }
}

# AWS subnet resource
resource "aws_subnet" "dev-pub-az-a" {
 vpc_id = aws_vpc.main-dev.id
 cidr_block = "10.11.1.0/24"
 availability_zone = data.aws_availability_zones.available-dev.names[0]
 map_public_ip_on_launch = "false"
 tags = {Name = "Terraform dev-pub-az-a"}
}

resource "aws_subnet" "dev-pub-az-c" {
 vpc_id = aws_vpc.main-dev.id
 cidr_block = "10.11.2.0/24"
 availability_zone = data.aws_availability_zones.available-dev.names[2]
 map_public_ip_on_launch = "false"
 tags = {Name = "Terraform dev-pub-az-c"}
}

resource "aws_subnet" "dev-pri-az-a" {
 vpc_id = aws_vpc.main-dev.id
 cidr_block = "10.11.3.0/24"
 availability_zone = data.aws_availability_zones.available-dev.names[0]
 map_public_ip_on_launch = "false"
 tags = {Name = "Terraform dev-pri-az-a"}
}

resource "aws_subnet" "dev-pri-az-c" {
 vpc_id = aws_vpc.main-dev.id
 cidr_block = "10.11.4.0/24"
 availability_zone = data.aws_availability_zones.available-dev.names[2]
 map_public_ip_on_launch = "false"
 tags = {Name = "Terraform dev-pri-az-c"}
}

# AWS internet resource
resource "aws_internet_gateway" "dev-ext-igw" {
  vpc_id = aws_vpc.main-dev.id
  tags = {
    Name = "Terraform dev-ext-igw"
  }
}

# AWS EIP resource
resource "aws_eip" "dev-nat-eip" {
  vpc      = true
  tags = {Name = "dev-nat-eip"}
}

# AWS NAT resource
resource "aws_nat_gateway" "dev-nat-gw" {
  allocation_id = aws_eip.dev-nat-eip.id
  subnet_id     = aws_subnet.dev-pub-az-c.id

  tags = {
    Name = "Terraform dev-nat-gw"
  }
}

# AWS route table resource
resource "aws_route_table" "dev-pub-rt" {
  vpc_id = aws_vpc.main-dev.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-ext-igw.id
  }
  tags = {Name = "Terraform-dev-pub-rt"}
}

resource "aws_route_table" "dev-pri-rt" {
  vpc_id = aws_vpc.main-dev.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.dev-nat-gw.id
  }
  tags = {Name = "Terraform-dev-pri-rt"}
}

# route table attached subnet
resource "aws_route_table_association" "dev-pub-rt-association-a" {
  route_table_id = aws_route_table.dev-pub-rt.id
  subnet_id      = aws_subnet.dev-pub-az-a.id
}

resource "aws_route_table_association" "dev-pub-rt-association-c" {
  route_table_id = aws_route_table.dev-pub-rt.id
  subnet_id      = aws_subnet.dev-pub-az-c.id
}

resource "aws_route_table_association" "dev-pri-rt-association-a" {
  route_table_id = aws_route_table.dev-pri-rt.id
  subnet_id     = aws_subnet.dev-pri-az-a.id
}

resource "aws_route_table_association" "dev-pri-rt-association-c" {
  route_table_id = aws_route_table.dev-pri-rt.id
  subnet_id     = aws_subnet.dev-pri-az-c.id
}

# security group create
resource "aws_security_group" "dev-terraform-ec2-gs" {
  vpc_id = aws_vpc.main-dev.id
  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol = "tcp"
    from_port = 3389
    to_port = 65535
    cidr_blocks = [aws_vpc.main-dev.cidr_block]
  }
  tags = {Name = "terraform-dev-ec2-gs"}
}

# pub dev ec2 create
resource "aws_instance" "dev-web" {
  ami           = "ami-027ce4ce0590e3c98"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.dev-pub-az-a.id
  root_block_device {
    volume_size = 11
    volume_type = "gp2"
  }
  vpc_security_group_ids = [aws_security_group.dev-terraform-ec2-gs.id]
  key_name = "kimkey"
  tags = {Name = "Terraform dev-ec2"}
}

# pub dev ec2 volume create
resource "aws_ebs_volume" "dev-volume2a" {
  availability_zone = "ap-northeast-2a"
  size              = 1
}

# pub dev ec2 volume attached
resource "aws_volume_attachment" "dev-ebs_att-2a" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.dev-volume2a.id
  instance_id = aws_instance.dev-web.id
}


# ================================================================================================ #

# VPC-PRD config
# Retrieve the AZ where we want to create network resources
data "aws_availability_zones" "available-prd" {}

# VPC Resource
resource "aws_vpc" "main-prd" {
  cidr_block = "10.51.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "Terraform VPC"
  }
}

# AWS subnet resource
resource "aws_subnet" "prd-pub-az-a" {
 vpc_id = aws_vpc.main-prd.id
 cidr_block = "10.51.1.0/24"
 availability_zone = data.aws_availability_zones.available-prd.names[0]
 map_public_ip_on_launch = "false"
 tags = {Name = "Terraform prd-pub-az-a"}
}

resource "aws_subnet" "prd-pub-az-c" {
 vpc_id = aws_vpc.main-prd.id
 cidr_block = "10.51.2.0/24"
 availability_zone = data.aws_availability_zones.available-prd.names[2]
 map_public_ip_on_launch = "false"
 tags = {Name = "Terraform prd-pub-az-c"}
}

resource "aws_subnet" "prd-pri-az-a" {
 vpc_id = aws_vpc.main-prd.id
 cidr_block = "10.51.3.0/24"
 availability_zone = data.aws_availability_zones.available-prd.names[0]
 map_public_ip_on_launch = "false"
 tags = {Name = "Terraform prd-pri-az-a"}
}

resource "aws_subnet" "prd-pri-az-c" {
 vpc_id = aws_vpc.main-prd.id
 cidr_block = "10.51.4.0/24"
 availability_zone = data.aws_availability_zones.available-prd.names[2]
 map_public_ip_on_launch = "false"
 tags = {Name = "Terraform prd-pri-az-c"}
}

# AWS internet resource
resource "aws_internet_gateway" "prd-ext-igw" {
  vpc_id = aws_vpc.main-prd.id
  tags = {
    Name = "Terraform prd-ext-igw"
  }
}

# AWS EIP resource
resource "aws_eip" "prd-nat-eip" {
  vpc      = true
  tags = {Name = "prd-nat-eip"}
}

# AWS NAT resource
resource "aws_nat_gateway" "prd-nat-gw" {
  allocation_id = aws_eip.prd-nat-eip.id
  subnet_id     = aws_subnet.prd-pub-az-c.id

  tags = {
    Name = "Terraform prd-nat-gw"
  }
}

# AWS route table resource
resource "aws_route_table" "prd-pub-rt" {
  vpc_id = aws_vpc.main-prd.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prd-ext-igw.id
  }
  tags = {Name = "Terraform-prd-pub-rt"}
}

resource "aws_route_table" "prd-pri-rt" {
  vpc_id = aws_vpc.main-prd.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.prd-nat-gw.id
  }
  tags = {Name = "Terraform-prd-pri-rt"}
}

# route table attached subnet
resource "aws_route_table_association" "prd-pub-rt-association-a" {
  route_table_id = aws_route_table.prd-pub-rt.id
  subnet_id      = aws_subnet.prd-pub-az-a.id
}

resource "aws_route_table_association" "prd-pub-rt-association-c" {
  route_table_id = aws_route_table.prd-pub-rt.id
  subnet_id      = aws_subnet.prd-pub-az-c.id
}

resource "aws_route_table_association" "prd-pri-rt-association-a" {
  route_table_id = aws_route_table.prd-pri-rt.id
  subnet_id     = aws_subnet.prd-pri-az-a.id
}

resource "aws_route_table_association" "prd-pri-rt-association-c" {
  route_table_id = aws_route_table.prd-pri-rt.id
  subnet_id     = aws_subnet.prd-pri-az-c.id
}

# security group create
resource "aws_security_group" "prd-terraform-ec2-gs" {
  vpc_id = aws_vpc.main-prd.id
  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol = "tcp"
    from_port = 3389
    to_port = 65535
    cidr_blocks = [aws_vpc.main-prd.cidr_block]
  }
  tags = {Name = "terraform-prd-ec2-gs"}
}

# pub prd ec2 create
resource "aws_instance" "prd-web" {
  ami           = "ami-027ce4ce0590e3c98"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.prd-pub-az-a.id
  root_block_device {
    volume_size = 11
    volume_type = "gp2"
  }
  vpc_security_group_ids = [aws_security_group.prd-terraform-ec2-gs.id]
  key_name = "kimkey"
  tags = {Name = "Terraform prd-ec2"}
}

# pub prd ec2 volume create
resource "aws_ebs_volume" "prd-volume2a" {
  availability_zone = "ap-northeast-2a"
  size              = 1
}

# pub prd ec2 volume attached
resource "aws_volume_attachment" "prd-ebs-att-2a" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.prd-volume2a.id
  instance_id = aws_instance.prd-web.id
}

# ================================================================================================ #

# PRD-DEV transit gateway 연결

# transit gateway create
resource "aws_ec2_transit_gateway" "prd-dev-transitgateway" {
  description = "prd-dev-transitgateway"
  tags = {name = "prd-dev-transitgateway"}
}

# transit gateway connection
resource "aws_ec2_transit_gateway_vpc_attachment" "dev-transitgateway-attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.prd-dev-transitgateway.id
  vpc_id             = aws_vpc.main-dev.id
  subnet_ids         = [aws_subnet.dev-pub-az-a.id,aws_subnet.dev-pub-az-c.id]
  dns_support        = "enable"
  tags = {Name = "dev-transitgateway-attachment"}
}

resource "aws_ec2_transit_gateway_vpc_attachment" "prd-transitgateway-attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.prd-dev-transitgateway.id
  vpc_id             = aws_vpc.main-prd.id
  subnet_ids         = [aws_subnet.prd-pub-az-a.id,aws_subnet.prd-pub-az-c.id]
  dns_support        = "enable"
  tags = {Name = "prd-transitgateway-attachment"}
}

# route table transit gateway connection
resource "aws_route" "route-dev-pub-transitgateway" {
	route_table_id = aws_route_table.dev-pub-rt.id
	destination_cidr_block = aws_vpc.main-prd.cidr_block
	transit_gateway_id = aws_ec2_transit_gateway.prd-dev-transitgateway.id
}

resource "aws_route" "route-dev-pri-transitgateway" {
	route_table_id = aws_route_table.dev-pri-rt.id
	destination_cidr_block = aws_vpc.main-prd.cidr_block
	transit_gateway_id = aws_ec2_transit_gateway.prd-dev-transitgateway.id
}

resource "aws_route" "route-prd-pub-transitgateway" {
	route_table_id = aws_route_table.prd-pub-rt.id
	destination_cidr_block = aws_vpc.main-dev.cidr_block
	transit_gateway_id = aws_ec2_transit_gateway.prd-dev-transitgateway.id
}

resource "aws_route" "route-prd-pri-transitgateway" {
	route_table_id = aws_route_table.prd-pri-rt.id
	destination_cidr_block = aws_vpc.main-dev.cidr_block
	transit_gateway_id = aws_ec2_transit_gateway.prd-dev-transitgateway.id
}

